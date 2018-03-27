use v6.c;

unit class Math::Matrix:ver<0.2.0>:auth<github:pierre-vigier>;
use AttrX::Lazy;

has @!rows is required;
has $!diagonal is lazy;

has Int $!row-count;
has Int $!column-count;

has Bool $!is-zero is lazy;
has Bool $!is-identity is lazy;
has Bool $!is-diagonal is lazy;
has Bool $!is-lower-triangular is lazy;
has Bool $!is-upper-triangular is lazy;
has Bool $!is-square is lazy;
has Bool $!is-symmetric is lazy;
has Bool $!is-antisymmetric is lazy;
has Bool $!is-self-adjoint is lazy;
has Bool $!is-unitary is lazy;
has Bool $!is-orthogonal is lazy;
has Bool $!is-invertible is lazy;
has Bool $!is-positive-definite is lazy;
has Bool $!is-positive-semidefinite is lazy;

has Numeric $!trace is lazy;
has Numeric $!determinant is lazy;
has Rat $!density is lazy;
has Int $!rank is lazy;
has Int $!kernel is lazy;

method !rows       { @!rows }
method !clone_rows  { AoA_clone(@!rows) }
method !row-count    { $!row-count }
method !column-count  { $!column-count }

subset Positive_Int of Int where * > 0 ;

################################################################################
# start constructors
################################################################################

method new( @m ) {
    die "Expect an Array of Array" unless all @m ~~ Array;
    die "All Row must contains the same number of elements" unless @m[0] == all @m[*];
    die "All Row must contains only numeric values" unless all( @m[*;*] ) ~~ Numeric;
    self.bless( rows => @m );
}

method clone { self.bless( rows => @!rows ) }

sub AoA_clone (@m)  {  map {[ map {$^cell.clone}, $^row.flat ]}, @m }

submethod BUILD( :@rows!, :$diagonal, :$density, :$trace, :$determinant, :$rank, :$kernel,
                 :$is-zero, :$is-identity, :$is-symmetric, :$is-upper-triangular, :$is-lower-triangular ) {
    @!rows = AoA_clone (@rows);
    $!row-count = @rows.elems;
    $!column-count = @rows[0].elems;
    $!diagonal = $diagonal if $diagonal.defined;
    $!density  = $density if $density.defined;
    $!trace    = $trace if $trace.defined;
    $!determinant = $determinant if $determinant.defined;
    $!rank   = $rank if $rank.defined;
    $!kernel = $kernel if $kernel.defined;
    $!is-zero = $is-zero if $is-zero.defined;
    $!is-identity = $is-identity if $is-identity.defined;
    $!is-symmetric = $is-symmetric if $is-symmetric.defined;
    $!is-upper-triangular = $is-upper-triangular if $is-upper-triangular.defined;
    $!is-lower-triangular = $is-lower-triangular if $is-lower-triangular.defined;
}

sub zero_array( Positive_Int $rows, Positive_Int $cols = $rows ) {
    return [ [ 0 xx $cols ] xx $rows ];
}
multi method new-zero(Math::Matrix:U: Positive_Int $size) {
    self.bless( rows => zero_array($size, $size),
            determinant => 0, rank => 0, kernel => $size, density => 0.0, trace => 0,
            is-zero => True, is-identity => False, is-diagonal => True, 
            is-square => True, is-symmetric => True  );
}
multi method new-zero(Math::Matrix:U: Positive_Int $rows, Positive_Int $cols) {
    self.bless( rows => zero_array($rows, $cols),
            determinant => 0, rank => 0, kernel => min($rows, $cols), density => 0.0, trace => 0,
            is-zero => True, is-identity => False, is-diagonal => ($cols == $rows),  );
}

sub identity_array( Positive_Int $size ) {
    my @identity;
    for ^$size X ^$size -> ($r, $c) { @identity[$r][$c] = ($r == $c ?? 1 !! 0) }
    return @identity;
}

method new-identity(Math::Matrix:U: Positive_Int $size ) {
    self.bless( rows => identity_array($size), diagonal => (1) xx $size, 
                determinant => 1, rank => $size, kernel => 0, density => 1/$size, trace => $size,
                is-zero => False, is-identity => True, 
                is-square => True, is-diagonal => True, is-symmetric => True );
}

method new-diagonal(Math::Matrix:U: *@diag ){
    fail "Expect an List of Number" unless @diag and [and] @diag >>~~>> Numeric;
    my Int $size = +@diag;
    my @d = zero_array($size, $size);
    (^$size).map: { @d[$_][$_] = @diag[$_] };

    self.bless( rows => @d, diagonal => @diag,
                determinant => [*](@diag.flat), trace => [+] (@diag.flat),
                is-square => True, is-diagonal => True, is-symmetric => True  );
}

method !new-lower-triangular(Math::Matrix:U: @m ) {
    #don't want to trust outside of the class that a matrix is really triangular
    self.bless( rows => @m, is-lower-triangular => True );
}

method !new-upper-triangular(Math::Matrix:U: @m ) {
    #don't want to trust outside of the class that a matrix is really triangular
    self.bless( rows => @m, is-upper-triangular => True );
}

method new-vector-product (Math::Matrix:U: @column_vector, @row_vector ){
    fail "Expect two Lists of Number" unless [and](@column_vector >>~~>> Numeric) and [and](@row_vector >>~~>> Numeric);
    my @p;
    for ^+@column_vector X ^+@row_vector -> ($r, $c) { 
        @p[$r][$c] = @column_vector[$r] * @row_vector[$c] 
    }
    self.bless( rows => @p, determinant => 0 , rank => 1 );
}

################################################################################
# end of constructor - start accessors
################################################################################

multi submethod check_row_index       (Int $row) { self.check_index($row, 0) }
multi submethod check_row_index       (    @row) { self.check_index(@row, ()) }
multi submethod check_column_index    (Int $col) { self.check_index(0, $col)  }
multi submethod check_column_index    (    @col) { self.check_index((), @col) }
multi submethod check_index (Int $row, Int $col) {
    fail X::OutOfRange.new(:what<Row Index>,   :got($row),:range(0 .. $!row-count - 1))
        unless 0 <= $row < $!row-count;
    fail X::OutOfRange.new(:what<Column Index>,:got($col),:range(0 .. $!column-count - 1))
        unless 0 <= $col < $!column-count;
}
multi submethod check_index (@rows, @cols) {
    fail X::OutOfRange.new(
        :what<Row index> , :got(@rows), :range("0..{$!row-count -1 }")
    ) unless 0 <= all(@rows) < $!row-count;
    fail X::OutOfRange.new(
        :what<Column index> , :got(@cols), :range("0..{$!column-count -1 }")
    ) unless 0 <= all(@cols) < $!column-count;
}

method cell(Math::Matrix:D: Int:D $row, Int:D $column --> Numeric ) {
    self.check_index($row, $column);
    return @!rows[$row][$column];
}

method row(Math::Matrix:D: Int:D $row  --> List) {
    self.check_row_index($row);
    return @!rows[$row].list;
}

method column(Math::Matrix:D: Int:D $column --> List) {
    self.check_column_index($column);
    (@!rows.keys.map:{ @!rows[$_;$column] }).list;
}

method !build_diagonal(Math::Matrix:D: --> List){
    fail "Number of columns has to be same as number of rows" unless self.is-square;
    ( gather for ^$!row-count -> $i { take @!rows[$i;$i] } ).list;
}


multi method submatrix(Math::Matrix:D: Int:D $row, Int:D $column --> Math::Matrix:D ){
    self.check_index($row, $column);
    my @rows = ^$!row-count;     @rows.splice($row,1);
    my @cols = ^$!column-count;  @cols.splice($column,1);
    self.submatrix(@rows ,@cols);
}
multi method submatrix(Math::Matrix:D: Int:D $row-min, Int:D $col-min, Int:D $row-max, Int:D $col-max --> Math::Matrix:D ){
    fail "Minimum row has to be smaller than maximum row" if $row-min > $row-max;
    fail "Minimum column has to be smaller than maximum column" if $col-min > $col-max;
    self.submatrix(($row-min .. $row-max).list, ($col-min .. $col-max).list);
}
multi method submatrix(Math::Matrix:D: @rows where .all ~~ Int, @cols where .all ~~ Int --> Math::Matrix:D ){
    self.check_index(@rows, @cols);
    Math::Matrix.new([ @rows.map( { [ @!rows[$_][|@cols] ] } ) ]);
}

################################################################################
# end of accessors - start with type conversion and handy shortcuts
################################################################################

method Bool(Math::Matrix:D: --> Bool)    { ! self.is-zero }
method Numeric (Math::Matrix:D: --> Int) {   self.elems   }
method Str(Math::Matrix:D: --> Str)      {   @!rows.gist  }

multi method perl(Math::Matrix:D: --> Str) {
  self.WHAT.perl ~ ".new(" ~ @!rows.perl ~ ")";
}

method list-rows(Math::Matrix:D: --> List) {
    (@!rows.map: {$_.flat}).list;
}

method list-columns(Math::Matrix:D: --> List) {
    ((0 .. $!column-count - 1).map: {self.column($_)}).list;
}

method gist(Math::Matrix:D: --> Str) {
    my $max-rows = 20;
    my $max-chars = 80;
    my $max-nr-char = max( @!rows[*;*] ).Int.chars;  # maximal pre digit char in cell
    my $cell_with;
    my $fmt;
    if all( @!rows[*;*] ) ~~ Int {
        $fmt = " %{$max-nr-char}d ";
        $cell_with = $max-nr-char + 2;
    } else {
        my $max-decimal = max( @!rows[*;*].map( { ( .split(/\./)[1] // '' ).chars } ) );
        $max-decimal = 5 if $max-decimal > 5; #more than that is not readable
        $max-nr-char += $max-decimal + 1;
        $fmt = " \%{$max-nr-char}.{$max-decimal}f ";
        $cell_with = $max-nr-char + 3 + $max-decimal;
    }
    my $rows = min $!row-count, $max-rows;
    my $cols = min $!column-count, $max-chars div $cell_with;
    my $row-addon = $!column-count > $cols ?? '..' !! '';
    my $str;
    for @!rows[0 .. $rows-1] -> $r {
        $str ~= ( [~] $r.[0..$cols-1].map( { $_.fmt($fmt) } ) ) ~ "$row-addon\n";
    }
    $str ~= " ...\n" if $!row-count > $max-rows;
    $str.chomp;
}

method full (Math::Matrix:D: --> Str) {
    my $max-char = max( @!rows[*;*] ).Int.chars;
    my $fmt;
    if all( @!rows[*;*] ) ~~ Int {
        $fmt = " %{$max-char}d ";
    } else {
        my $max-decimal = max( @!rows[*;*].map( { ( .split(/\./)[1] // '' ).chars } ) );
        $max-decimal = 5 if $max-decimal > 5; #more than that is not readable
        $max-char += $max-decimal + 1;
        $fmt = " \%{$max-char}.{$max-decimal}f ";
    }
    my $str;
    for @!rows -> $r {
        $str ~= ( [~] $r.map( { $_.fmt($fmt) } ) ) ~ "\n";
    }
    $str;
}

sub insert ($x, @xs) { ([flat @xs[0 ..^ $_], $x, @xs[$_ .. *]] for 0 .. @xs) }
sub order ($sg, @xs) { $sg > 0 ?? @xs !! @xs.reverse }

multi σ_permutations ([]) { [] => 1 }
multi σ_permutations ([$x, *@xs]) {
    σ_permutations(@xs).map({ |order($_.value, insert($x, $_.key)) }) Z=> |(1,-1) xx *
}

################################################################################
# end of type conversion and handy shortcuts - start boolean matrix properties
################################################################################

method !build_is-square(Math::Matrix:D: --> Bool) { $!column-count == $!row-count }

method !build_is-zero(Math::Matrix:D: --> Bool)   { self.density() == 0 }

method !build_is-identity(Math::Matrix:D: --> Bool) {
    return False unless self.is-square;
    for ^$!row-count X ^$!column-count -> ($r, $c) {
        return False unless @!rows[$r][$c] == ($r == $c ?? 1 !! 0);
    }
    True;
}

method !build_is-upper-triangular(Math::Matrix:D: --> Bool) {
    return False unless self.is-square;
    for ^$!row-count X ^$!column-count -> ($r, $c) {
        return False if @!rows[$r][$c] != 0 and $r > $c;
    }
    True;
}

method !build_is-lower-triangular(Math::Matrix:D: --> Bool) {
    return False unless self.is-square;
    for ^$!row-count X ^$!column-count -> ($r, $c) {
        return False if @!rows[$r][$c] != 0 and $r < $c;
    }
    True;
}

method !build_is-diagonal(Math::Matrix:D: --> Bool) {
    return $.is-upper-triangular && $.is-lower-triangular;
}

method is-diagonally-dominant(Math::Matrix:D: Bool :$strict = False, Str :$along where {$^orient eq any <column row both>} = 'column' --> Bool) {
    return False unless self.is-square;
    my $greater = $strict ?? &[>] !! &[>=];
    my Bool $colwise;
    if $along ~~ any <column both> {
        $colwise = [and] map {my $c = $_; &$greater( @!rows[$c][$c] * 2, 
                                                     [+](map {abs $_[$c]}, @!rows)) }, ^$!row-count;
    }
    return $colwise if $along eq 'column';
    my Bool $rowwise = [and] map { &$greater( @!rows[$^r][$^r] * 2, 
                                              [+](map {abs $^c}, @!rows[$^r].flat)) }, ^$!row-count;
    return $rowwise if $along eq 'row';
    $colwise and $rowwise;
}

method !build_is-symmetric(Math::Matrix:D: --> Bool) {
    return False unless self.is-square;
    return True if $!row-count < 2;
    for ^($!row-count - 1) -> $r {
        for $r ^..^ $!row-count -> $c {
            return False unless @!rows[$r][$c] == @!rows[$c][$r];
        }
    }
    True;
}
method !build_is-antisymmetric(Math::Matrix:D: --> Bool) {
    return False unless self.is-square;
    return True if $!row-count < 2;
    for ^($!row-count - 1) -> $r {
        for $r ^..^ $!row-count -> $c {
            return False unless @!rows[$r][$c] == - @!rows[$c][$r];
        }
    }
    True;
}

method !build_is-self-adjoint(Math::Matrix:D: --> Bool) {
    return False unless self.is-square;
    self.T.conj ~~ self;
}

method !build_is-unitary(Math::Matrix:D: --> Bool) {
    return False unless self.is-square;
    self.dotProduct( self.T.conj ) ~~ Math::Matrix.new-identity( $!row-count );
}

method !build_is-orthogonal(Math::Matrix:D: --> Bool) {
    return False unless self.is-square;
    self.dotProduct( self.T ) ~~ Math::Matrix.new-identity( $!row-count );
}

method !build_is-invertible(Math::Matrix:D: --> Bool) {
    self.is-square and self.determinant != 0;
}

method !build_is-positive-definite (Math::Matrix:D: --> Bool) { # with Sylvester's criterion
    return False unless self.is-square;
    return False unless self.determinant > 0;
    my $sub = Math::Matrix.new( @!rows );
    for $!row-count - 1 ... 1 -> $r {
        $sub = $sub.submatrix(0,0,$r,$r);
        return False unless $sub.determinant > 0;
    }
    True;
}

method !build_is-positive-semidefinite (Math::Matrix:D: --> Bool) { # with Sylvester's criterion
    return False unless self.is-square;
    return False unless self.determinant >= 0;
    my $sub = Math::Matrix.new( @!rows );
    for $!row-count - 1 ... 1 -> $r {
        $sub = $sub.submatrix(0,0,$r,$r);
        return False unless $sub.determinant >= 0;
    }
    True;
}

################################################################################
# end of boolean matrix properties - start numeric matrix properties
################################################################################

method size(Math::Matrix:D: )          {  $!row-count, $!column-count }

method !build_density(Math::Matrix:D: --> Rat) {
    my $valcount = 0;
    for ^$!row-count X ^$!column-count -> ($r, $c) { $valcount++ if @!rows[$r][$c] != 0 }
    $valcount / self.elems;
}

method !build_trace(Math::Matrix:D: --> Numeric) {
    self.diagonal.sum;
}

method det(Math::Matrix:D: --> Numeric )        { self.determinant }  # the usual short name
method !build_determinant(Math::Matrix:D: --> Numeric) {
    fail "Number of columns has to be same as number of rows" unless self.is-square;
    return 1            if $!row-count == 0;
    return @!rows[0][0] if $!row-count == 1;
    if $!row-count > 4 {
        #up to 4x4 naive method is fully usable
        return [*] $.diagonal.flat if $.is-upper-triangular || $.is-lower-triangular;
        try {
            my ($L, $U, $P) = $.decompositionLU();
            return $P.inverted.det * $L.det * $U.det;
        }
    }
    my $det = 0;
    for ( σ_permutations([^$!row-count]) ) {
        my $permutation = .key;
        my $product = .value;
        for $permutation.kv -> $i, $j { $product *= @!rows[$i][$j] };
        $det += $product;
    }
    $!determinant = $det;
}
method determinant-naive(Math::Matrix:D: --> Numeric) {
    fail "Number of columns has to be same as number of rows" unless self.is-square;
    return 1            if $!row-count == 0;
    return @!rows[0][0] if $!row-count == 1;
    my $det = 0;
    for ( σ_permutations([^$!row-count]) ) {
        my $permutation = .key;
        my $product = .value;
        for $permutation.kv -> $i, $j { $product *= @!rows[$i][$j] };
        $det += $product;
    }
    $det;
}

method !build_rank(Math::Matrix:D: --> Int) {
    my $rank = 0;
    my @clone =  @!rows.clone();
    for ^$!column-count -> $c {            # make upper triangle via gauss elimination
        last if $rank == $!row-count;      # rank cant get bigger thean dim
        my $swap_row_nr = $rank;
        $swap_row_nr++ while $swap_row_nr < $!row-count and @clone[$swap_row_nr][$c] == 0;
        next if $swap_row_nr == $!row-count;
        (@clone[$rank], @clone[$swap_row_nr]) = (@clone[$swap_row_nr], @clone[$rank]);
        for $rank + 1 ..^ $!row-count -> $r {
            next if @clone[$r][$c] == 0;
            my $q = @clone[$rank][$c] / @clone[$r][$c];
            @clone[$r] = @clone[$rank] >>-<< $q <<*<< @clone[$r];
        }
        $rank++;
    }
    $rank;
}

method !build_kernel(Math::Matrix:D: --> Int) {
    min(self.size) - self.rank;
}

multi method norm(Math::Matrix:D: Positive_Int :$p = 2, Positive_Int :$q = 1 --> Numeric) {
    my $norm = 0;
    for ^$!column-count -> $c {
        my $col_sum = 0;
        for ^$!row-count -> $r {  $col_sum += abs(@!rows[$r][$c]) ** $p }
        $norm += $col_sum ** ($q / $p);
    }
    $norm ** (1/$q);
}
multi method norm(Math::Matrix:D: Str $which where * eq 'row-sum' --> Numeric) {
    max map {[+] map {abs $_}, @$_}, @!rows;
}
multi method norm(Math::Matrix:D: Str $which where * eq 'column-sum' --> Numeric) {
    max map {my $c = $_; [+](map {abs $_[$c]}, @!rows) }, ^$!column-count;
}
multi method norm(Math::Matrix:D: Str $which where * eq 'max' --> Numeric) {
    max map {max map {abs $_},  @$_}, @!rows;
}

method condition(Math::Matrix:D: --> Numeric) {
    self.norm() * self.inverted().norm();
}

################################################################################
# end of numeric matrix properties - start create derivative matrices
################################################################################

method T(Math::Matrix:D: --> Math::Matrix:D  )         { self.transposed }
method transposed(Math::Matrix:D: --> Math::Matrix:D ) {
    my @transposed;
    for ^$!row-count X ^$!column-count -> ($r, $c) { @transposed[$c][$r] = @!rows[$r][$c] }
    Math::Matrix.new( @transposed );
}

method inverted(Math::Matrix:D: --> Math::Matrix:D) {
    fail "Number of columns has to be same as number of rows" unless self.is-square;
    fail "Matrix is not invertible, or singular because defect (determinant = 0)" if self.determinant == 0;
    my @clone = self!clone_rows();
    my @inverted = identity_array( $!row-count );
    for ^$!row-count -> $c {
        my $swap_row_nr = $c;       # make sure that diagonal element != 0, later == 1
        $swap_row_nr++ while @clone[$swap_row_nr][$c] == 0;
        (@clone[$c], @clone[$swap_row_nr])       = (@clone[$swap_row_nr], @clone[$c]);
        (@inverted[$c], @inverted[$swap_row_nr]) = (@inverted[$swap_row_nr], @inverted[$c]);
        @inverted[$c] =  @inverted[$c] >>/>>  @clone[$c][$c];
        @clone[$c]    =  @clone[$c]    >>/>>  @clone[$c][$c];
        for $c + 1 ..^ $!row-count -> $r {
            @inverted[$r] = @inverted[$r]  >>-<<  @clone[$r][$c] <<*<< @inverted[$c];
            @clone[$r]    = @clone[$r]  >>-<<  @clone[$r][$c] <<*<< @clone[$c];
        }
    }
    for reverse(1 ..^ $!column-count) -> $c {
        for ^$c -> $r {
            @inverted[$r] = @inverted[$r]  >>-<<  @clone[$r][$c] <<*<< @inverted[$c];
            @clone[$r]    = @clone[$r]  >>-<<  @clone[$r][$c] <<*<< @clone[$c];
        }
    }
    Math::Matrix.new( @inverted );
}

method negated(Math::Matrix:D: --> Math::Matrix:D )       { self.map( - * ) }

method conj(Math::Matrix:D: --> Math::Matrix:D  )         { self.conjugated }
method conjugated(Math::Matrix:D: --> Math::Matrix:D ) {
    self.map( { $_.conj} );
}

method reduced-row-echelon-form(Math::Matrix:D: --> Math::Matrix:D) {
    my @ref = self!clone_rows();
    my $lead = 0;
    MAIN: for ^$!row-count -> $r {
        last MAIN if $lead >= $!column-count;
        my $i = $r;
        while @ref[$i][$lead] == 0 {
            $i++;
            if $!row-count == $i {
                $i = $r;
                $lead++;
                last MAIN if $lead == $!column-count;
            }
        }
        @ref[$i, $r] = @ref[$r, $i];
        my $lead_value = @ref[$r][$lead];
        @ref[$r] »/=» $lead_value;
        for ^$!row-count -> $n {
            next if $n == $r;
            @ref[$n] »-=» @ref[$r] »*» @ref[$n][$lead];
        }
        $lead++;
    }
    return Math::Matrix.new( @ref );
}
method rref(Math::Matrix:D: --> Math::Matrix:D) {
    self.reduced-row-echelon-form;
}

################################################################################
# end of derivative matrices - start decompositions
################################################################################

# LU factorization with optional partial pivoting and optional diagonal matrix
multi method decompositionLU(Math::Matrix:D: Bool :$pivot = True, :$diagonal = False) {
    fail "Not an square matrix" unless self.is-square;
    fail "Has to be invertible when not using pivoting" if not $pivot and not self.is-invertible;
    my $size = self!row-count;
    my @L = identity_array( $size );
    my @U = self!clone_rows( );
    my @P = identity_array( $size );

    for 0 .. $size-2 -> $c {
        if $pivot {
            my $maxrow = $c;
            for $c+1 ..^$size -> $r { $maxrow = $c if @U[$maxrow][$c] < @U[$r][$c] }
            (@U[$maxrow], @U[$c]) = (@U[$c], @U[$maxrow]);
            (@P[$maxrow], @P[$c]) = (@P[$c], @P[$maxrow]);
        }
        for $c+1 ..^$size -> $r {
            next if @U[$r][$c] == 0;
            my $q = @L[$r][$c] = @U[$r][$c] / @U[$c][$c];
            @U[$r] = @U[$r] >>-<< $q <<*<< @U[$c];
        }
    }
    if $diagonal {
        my @D;
        for 0 ..^ $size -> $c {
            push @D, @U[$c][$c];
            @U[$c][$c] = 1;
        }
        $pivot ?? (Math::Matrix!new-lower-triangular(@L), Math::Matrix.new-diagonal(@D), Math::Matrix!new-upper-triangular(@U), Math::Matrix.new(@P))
               !! (Math::Matrix!new-lower-triangular(@L), Math::Matrix.new-diagonal(@D), Math::Matrix!new-upper-triangular(@U));
    }
    $pivot ?? (Math::Matrix!new-lower-triangular(@L), Math::Matrix!new-upper-triangular(@U), Math::Matrix.new(@P))
           !! (Math::Matrix!new-lower-triangular(@L), Math::Matrix!new-upper-triangular(@U));
}

method decompositionLUCrout(Math::Matrix:D: ) {
    fail "Not square matrix" unless self.is-square;
    my $sum;
    my $size = self!row-count;
    my $U = identity_array( $size );
    my $L = zero_array( $size );

    for 0 ..^$size -> $j {
        for $j ..^$size -> $i {
            $sum = [+] map {$L[$i][$_] * $U[$_][$j]}, 0..^$j;
            $L[$i][$j] = @!rows[$i][$j] - $sum;
        }
        if $L[$j][$j] == 0 { fail "det(L) close to 0!\n Can't divide by 0...\n" }

        for $j ..^$size -> $i {
            $sum = [+] map {$L[$j][$_] * $U[$_][$i]}, 0..^$j;
            $U[$j][$i] = (@!rows[$j][$i] - $sum) / $L[$j][$j];
        }
    }
    return Math::Matrix.new($L), Math::Matrix.new($U);
}

method decompositionCholesky(Math::Matrix:D: --> Math::Matrix:D) {
    fail "Not symmetric matrix" unless self.is-symmetric;
    fail "Not positive definite" unless self.is-positive-definite;
    my @D = self!clone_rows();
    for 0 ..^$!row-count -> $k {
        @D[$k][$k] -= @D[$k][$_]**2 for 0 .. $k-1;
        @D[$k][$k]  = sqrt @D[$k][$k];
        for $k+1 ..^ $!row-count -> $i {
            @D[$i][$k] -= @D[$i][$_] * @D[$k][$_] for 0 ..^ $k ;
            @D[$i][$k]  = @D[$i][$k] / @D[$k][$k];
        }
    }
    for ^$!row-count X ^$!column-count -> ($r, $c) { @D[$r][$c] = 0 if $r < $c }
    #return Math::Matrix.BUILD( rows => @D, is-lower-triangular => True );
    return Math::Matrix!new-lower-triangular( @D );
}

################################################################################
# end of decompositions - start list like operations
################################################################################

method equal(Math::Matrix:D: Math::Matrix $b --> Bool)           { @!rows ~~ $b!rows }
multi method ACCEPTS(Math::Matrix:D: Math::Matrix:D $b --> Bool) { self.equal( $b )  }

method elems (Math::Matrix:D: --> Int)               {  $!row-count * $!column-count }

multi method elem (Math::Matrix:D: Numeric $e  --> Bool) {
    self.map( {return True if $_ == $e});
    False;
}
multi method elem (Math::Matrix:D: Range $r  --> Bool) {
    self.map( {return True if $_ ~~ $r});
    False;
}

method map(Math::Matrix:D: &coderef --> Math::Matrix:D) {
    Math::Matrix.new( [ @!rows.map: {
            [ $_.map( &coderef ) ]
    } ] );
}

method map-row(Math::Matrix:D: Int $row, &coderef --> Math::Matrix:D ) {
    self.check_row_index($row);
    my @m = self!clone_rows;
    @m[$row] = @m[$row].map(&coderef);
    Math::Matrix.new( @m );
}

method map-column(Math::Matrix:D: Int $col, &coderef --> Math::Matrix:D ) {
    self.check_column_index($col);
    my @m = self!clone_rows;
    (^$!row-count).map:{ @m[$_;$col] = &coderef( @m[$_;$col] ) };
    Math::Matrix.new( @m );
}

method map-cell(Math::Matrix:D: Int $row, Int $col, &coderef --> Math::Matrix:D ) {
    self.check_index($row, $col);
    my @m = self!clone_rows;
    @m[$row;$col] = &coderef( @m[$row;$col] );
    Math::Matrix.new( @m );
}

method reduce(Math::Matrix:D: &coderef ) {
    (@!rows.map: {$_.flat}).flat.reduce( &coderef )
}

method reduce-rows (Math::Matrix:D: &coderef){
    @!rows.map: { $_.flat.reduce( &coderef ) }
}

method reduce-columns (Math::Matrix:D: &coderef){
    (^$!column-count).map: { self.column($_).reduce( &coderef ) }
}

################################################################################
# end of list like operations - start structural matrix operations
################################################################################

multi method move-row (Math::Matrix:D: Pair $p --> Math::Matrix:D) {
    self.move-row($p.key, $p.value) 
}
multi method move-row (Math::Matrix:D: Int $from, Int $to --> Math::Matrix:D) {
    self.check_row_index([$from, $to]);
    return self if $from == $to;
    my @rows = (^$!row-count).list;
    @rows.splice($to,0,@rows.splice($from,1));
    self.submatrix(@rows, (^$!column-count).list);
}

multi method move-column (Math::Matrix:D: Pair $p --> Math::Matrix:D) {
    self.move-column($p.key, $p.value) 
}
multi method move-column (Math::Matrix:D: Int $from, Int $to --> Math::Matrix:D) {
    self.check_column_index([$from, $to]);
    return self if $from == $to;
    my @cols = (^$!column-count).list;
    @cols.splice($to,0,@cols.splice($from,1));
    self.submatrix((^$!row-count).list, @cols);
}

method swap-rows (Math::Matrix:D: Int $rowa, Int $rowb --> Math::Matrix:D) {
    self.check_row_index([$rowa, $rowb]);
    return self if $rowa == $rowb;
    my @rows = (^$!row-count).list;
    (@rows.[$rowa], @rows.[$rowb]) = (@rows.[$rowb], @rows.[$rowa]);
    self.submatrix(@rows, (^$!column-count).list);
}

method swap-columns (Math::Matrix:D: Int $cola, Int $colb --> Math::Matrix:D) {
    self.check_column_index([$cola, $colb]);
    return self if $cola == $colb;
    my @cols = (^$!column-count).list;
    (@cols.[$cola], @cols.[$colb]) = (@cols.[$colb], @cols.[$cola]);
    self.submatrix((^$!row-count).list, @cols);
}


multi method prepend-vertically (Math::Matrix:D: $b --> Math::Matrix:D) {
    $b.append-vertically(self);
}
multi method prepend-vertically (Math::Matrix:D: Array $b --> Math::Matrix:D) {
    my @m;
    for $b.list -> $row {
        fail "Number of columns in matrix and data has to be same." unless $row.elems == $!column-count;
        fail "Data has to consist of numbers!" unless all($row.list) ~~ Numeric;
        @m.append( $row );
    }
    Math::Matrix.new( @m.append(self!clone_rows.list) );
}

multi method append-vertically (Math::Matrix:D: Math::Matrix:D $b --> Math::Matrix:D) {
    fail "Number of columns in both matrices has to be same" unless $!column-count == $b!column-count;
    my @m = self!clone_rows;
    Math::Matrix.new( @m.append( $b!rows.list ) );
}
multi method append-vertically (Math::Matrix:D: Array $b --> Math::Matrix:D) {
    my @m = self!clone_rows;
    for $b.list -> $row {
        fail "Number of columns in matrix and data has to be same." unless $row.elems == $!column-count;
        fail "Data has to consist of numbers!  $row" unless all($row.list) ~~ Numeric;
        @m.append( $row );
    }
    Math::Matrix.new(@m);
}

multi method prepend-horizontally (Math::Matrix:D: Math::Matrix:D $b --> Math::Matrix:D) {
    $b.append-horizontally(self);
}
multi method prepend-horizontally (Math::Matrix:D: Array $b --> Math::Matrix:D){
    fail "Number of rows in matrix and data has to be same." unless $b.elems == $!row-count;
    my $col = $b.elems[0].elems;
    my @m;
    for $b.kv -> $i, $row {
        fail "All rows in data need to have the same length" unless $row.elems == $row;
        fail "Data has to consist of numbers!  $row" unless all($row.list) ~~ Numeric;
        @m[$i] = $row.list.append( self!rows[$i].list );
    }
    Math::Matrix.new( @m );
}

multi method append-horizontally (Math::Matrix:D: Math::Matrix:D $b --> Math::Matrix:D){
    fail "Number of rows in both matrices has to be same" unless $!row-count == $b!row-count;
    my @m = self!clone_rows;
    @m.keys.map:{ @m[$_].append($b!rows[$_].list) };
    Math::Matrix.new( @m );
}
multi method append-horizontally (Math::Matrix:D: Array $b --> Math::Matrix:D){
    fail "Number of rows in matrix and data has to be same." unless $b.elems == $!row-count;
    my $col = $b.elems[0].elems;
    my @m = self!clone_rows;
    for $b.kv -> $i, $row {
        fail "All rows in data need to have the same length" unless $row.elems == $row;
        fail "Data has to consist of numbers!  $row" unless all($row.list) ~~ Numeric;
        @m[$i].append( $row.list );
    }
    Math::Matrix.new( @m );
}

# method split (){ }

################################################################################
# end of structural matrix operations - start matrix math operations
################################################################################

multi method add(Math::Matrix:D: Numeric $r --> Math::Matrix:D ) {
    self.map( * + $r );
}

multi method add(Math::Matrix:D: Math::Matrix $b where { $!row-count == $b!row-count and $!column-count == $b!column-count } --> Math::Matrix:D ) {
    my @sum;
    for ^$!row-count X ^$!column-count -> ($r, $c) {
        @sum[$r][$c] = @!rows[$r][$c] + $b!rows[$r][$c];
    }
    Math::Matrix.new( @sum );
}

multi method subtract(Math::Matrix:D: Numeric $r --> Math::Matrix:D ) {
    self.map( * - $r );
}

multi method subtract(Math::Matrix:D: Math::Matrix $b where { $!row-count == $b!row-count and $!column-count == $b!column-count } --> Math::Matrix:D ) {
    my @subtract;
    for ^$!row-count X ^$!column-count -> ($r, $c) {
        @subtract[$r][$c] = @!rows[$r][$c] - $b!rows[$r][$c];
    }
    Math::Matrix.new( @subtract );
}

method add-row(Math::Matrix:D: Int $row, @row where {.all ~~ Numeric} --> Math::Matrix:D ) {
    self.check_row_index($row);
    fail "Matrix has $!column-count columns, but got "~ +@row ~ "element row." unless $!column-count == +@row;
    my @m = self!clone_rows;
    @m[$row] = @m[$row] <<+>> @row;
    Math::Matrix.new( @m );
}

method add-column(Math::Matrix:D: Int $col, @col where {.all ~~ Numeric} --> Math::Matrix:D ) {
    self.check_column_index($col);
    fail "Matrix has $!row-count rows, but got "~ +@col ~ "element column." unless $!row-count == +@col;
    my @m = self!clone_rows;
    @col.keys.map:{ @m[$_][$col] += @col[$_] };
    Math::Matrix.new( @m );
}

multi method multiply(Math::Matrix:D: Numeric $r --> Math::Matrix:D ) {
    self.map( * * $r );
}

multi method multiply(Math::Matrix:D: Math::Matrix $b where { $!row-count == $b!row-count and $!column-count == $b!column-count } --> Math::Matrix:D ) {
    my @multiply;
    for ^$!row-count X ^$!column-count -> ($r, $c) {
        @multiply[$r][$c] = @!rows[$r][$c] * $b!rows[$r][$c];
    }
    Math::Matrix.new( @multiply );
}

method multiply-row(Math::Matrix:D: Int $row, Numeric $factor --> Math::Matrix:D ) {
    self.check_row_index($row);
    self.map-row($row,{$_ * $factor});
}

method multiply-column(Math::Matrix:D: Int $column, Numeric $factor --> Math::Matrix:D ) {
    self.map-column($column,{$_ * $factor});
}

method dotProduct(Math::Matrix:D: Math::Matrix $b --> Math::Matrix:D ) {
    fail "Number of columns of the second matrix is different from number of rows of the first operand"
        unless $!column-count == $b!row-count;
    my @product;
    for ^$!row-count X ^$b!column-count -> ($r, $c) {
        @product[$r][$c] += @!rows[$r][$_] * $b!rows[$_][$c] for ^$b!row-count;
    }
    Math::Matrix.new( @product );
}

method tensorProduct(Math::Matrix:D: Math::Matrix $b  --> Math::Matrix:D) {
    my @product;
    for @!rows -> $arow {
        for $b!rows -> $brow {
            @product.push([ ($arow.list.map: { $brow.flat >>*>> $_ }).flat ]);
        }
    }
    Math::Matrix.new( @product );
}

################################################################################
# end of matrix math operations - start operators
################################################################################

multi sub infix:<+>(::?CLASS $a, Numeric $n --> ::?CLASS:D ) is export { $a.add($n) }
multi sub infix:<+>(Numeric $n, ::?CLASS $a --> ::?CLASS:D ) is export { $a.add($n) }
multi sub infix:<+>(::?CLASS $a,::?CLASS $b --> ::?CLASS:D ) is export { $a.add($b) }

multi sub prefix:<->(::?CLASS $a            --> ::?CLASS:D ) is export { $a.negated() }
multi sub infix:<->(Numeric $n, ::?CLASS $a --> ::?CLASS:D ) is export { $a.negated.add($n) }
multi sub infix:<->(::?CLASS $a, Numeric $n --> ::?CLASS:D ) is export { $a.add(-$n)  }
multi sub infix:<->(::?CLASS $a,::?CLASS $b --> ::?CLASS:D ) is export { $a.subtract($b) }

multi sub infix:<*>(::?CLASS $a, Numeric $n --> ::?CLASS:D ) is export { $a.multiply($n) }
multi sub infix:<*>(Numeric $n, ::?CLASS $a --> ::?CLASS:D ) is export { $a.multiply($n) }
multi sub infix:<*>(::?CLASS $a,::?CLASS $b --> ::?CLASS:D ) is export { $a.multiply($b) }
multi sub infix:<**>(::?CLASS $a where { $a.is-square }, Int $e --> ::?CLASS:D ) is export {
    return Math::Matrix.new-identity( $a!row-count ) if $e ==  0;
    my $p = $a.clone;
    $p = $p.dotProduct( $a ) for 2 .. abs $e;
    $p = $p.inverted         if  $e < 0;
    $p;
}

multi sub infix:<⋅>( ::?CLASS $a, ::?CLASS $b --> ::?CLASS:D ) is looser(&infix:<*>) is export {
    $a.dotProduct( $b );
}
multi sub infix:<dot>(::?CLASS $a, ::?CLASS $b --> ::?CLASS:D ) is looser(&infix:<*>) is export {
    $a.dotProduct( $b );
}

multi sub infix:<÷>(::?CLASS $a,::?CLASS $b --> ::?CLASS:D ) is export { 
    $a.dotProduct( $b.inverted );
}

multi sub infix:<⊗>( ::?CLASS $a, ::?CLASS $b --> ::?CLASS:D ) is looser(&infix:<*>) is export {
    $a.tensorProduct( $b );
}
multi sub infix:<x>( ::?CLASS $a, ::?CLASS $b --> ::?CLASS:D ) is looser(&infix:<*>) is export {
    $a.tensorProduct( $b );
}

multi sub circumfix:<| |>(::?CLASS $a --> Numeric) is equiv(&prefix:<!>) is export { $a.determinant }
multi sub circumfix:<|| ||>(::?CLASS $a --> Numeric) is equiv(&prefix:<!>) is export { $a.norm }
