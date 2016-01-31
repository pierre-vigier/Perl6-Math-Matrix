unit class Math::Matrix;
use AttrX::Lazy;

has @!rows is required;
has Int $!row-count;
has Int $!column-count;
has $!diagonal is lazy;
has Bool $!is-square is lazy;
has Bool $!is-diagonal is lazy;
has Bool $!is-lower-triangular is lazy;
has Bool $!is-upper-triangular is lazy;
has Bool $!is-invertible is lazy;
has Bool $!is-zero is lazy;
has Bool $!is-identity is lazy;
has Bool $!is-orthogonal is lazy;
has Bool $!is-positive-definite  is lazy;
has Bool $!is-symmetric is lazy;
has Numeric $!trace is lazy;
has Numeric $!determinant is lazy;
has Rat $!density is lazy;
has Int $!rank is lazy;
has Int $!kernel is lazy;

method !rows      { @!rows }
method !clone_rows { AoA_clone(@!rows) }
method !row-count   { $!row-count }
method !column-count { $!column-count }

subset Positive_Int of Int where * > 0 ;


method new( @m ) {
    die "Expect an Array of Array" unless all @m ~~ Array;
    die "All Row must contains the same number of elements" unless @m[0] == all @m[*];
    die "All Row must contains only numeric values" unless all( @m[*;*] ) ~~ Numeric;
    self.bless( rows => @m );
}
method clone { self.bless( rows => @!rows ) }

sub AoA_clone (@m)  {  map {[ map {$^cell.clone}, $^row.flat ]}, @m }

submethod BUILD( :@rows!, :$determinant, :$rank, :$diagonal, :$is-upper-triangular, :$is-lower-triangular ) {
    @!rows = AoA_clone (@rows);
    $!row-count = @rows.elems;
    $!column-count = @rows[0].elems;
    $!determinant = $determinant if $determinant.defined;
    $!rank = $rank if $rank.defined;
    $!diagonal = $diagonal if $diagonal.defined;
    $!is-upper-triangular = $is-upper-triangular if $is-upper-triangular.defined;
    $!is-lower-triangular = $is-lower-triangular if $is-lower-triangular.defined;
}


method !zero_array( Positive_Int $rows, Positive_Int $cols = $rows ) {
    return [ [ 0 xx $cols ] xx $rows ];
}

method new-zero(Math::Matrix:U: Positive_Int $rows, Positive_Int $cols = $rows) {
    self.bless( rows => self!zero_array($rows, $cols), determinant => 0, rank => 0 );
}

method !identity_array( Positive_Int $size ) {
    my @identity;
    for ^$size X ^$size -> ($r, $c) { @identity[$r][$c] = ($r == $c ?? 1 !! 0) }
    return @identity;
}

method new-identity(Math::Matrix:U: Positive_Int $size ) {
    self.bless( rows => self!identity_array($size), determinant => 1, rank => $size, diagonal => (1) xx $size );
}

method new-diagonal(Math::Matrix:U: *@diag ){
    fail "Expect an List of Number" unless @diag and [and] @diag >>~~>> Numeric;
    my @d;
    for ^@diag.elems X ^@diag.elems -> ($r, $c) { @d[$r][$c] = $r==$c ?? @diag[$r] !! 0 }
    self.bless( rows => @d, determinant => [*](@diag) , rank => +@diag, diagonal => @diag );
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

method Str(Math::Matrix:D: --> Str) {
    @!rows.gist;
}

method Bool(Math::Matrix:D: --> Bool) {
    self.is-zero;
}

method Int(Math::Matrix:D: --> Int) {
    $!row-count * $!column-count;
}

multi method perl(Math::Matrix:D: --> Str) {
    self.WHAT.perl ~ ".new(" ~ @!rows.perl ~ ")";
}

method gist(Math::Matrix:D: --> Str) {
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

method ACCEPTS(Math::Matrix $b --> Bool ) {
    self.equal( $b );
}

multi method cell(Math::Matrix:D: Int $row, Int $column --> Numeric ) {
    fail X::OutOfRange.new(
        :what<Row index> , :got($row), :range("0..{$!row-count -1 }")
    ) unless 0 <= $row < $!row-count;
    fail X::OutOfRange.new(
        :what<Column index> , :got($column), :range("0..{$!column-count -1 }")
    ) unless 0 <= $column < $!column-count;
    return @!rows[$row][$column];
}

method !build_diagonal(Math::Matrix:D: ){
    fail "Number of columns has to be same as number of rows" unless self.is-square;
    gather for ^$!row-count -> $i { take @!rows[$i;$i] };
}

multi method submatrix(Math::Matrix:D: Int $row, Int $col --> Math::Matrix:D ){
    fail "$row is not an existing row index" unless 0 <= $row < $!row-count;
    fail "$col is not an existing column index" unless 0 <= $col < $!column-count;
    my @clone = self!clone_rows();
    @clone.splice($row,1);
    @clone = map { $^r.splice($col, 1); $^r }, @clone;
    Math::Matrix.new( @clone );
}

multi method submatrix(Math::Matrix:D: @rows, @cols --> Math::Matrix:D ){
    fail X::OutOfRange.new(
        :what<Column index> , :got(@cols), :range("0..{$!column-count -1 }")
    ) unless 0 <= all(@cols) < $!column-count;
    fail X::OutOfRange.new(
        :what<Column index> , :got(@rows), :range("0..{$!row-count -1 }")
    ) unless 0 <= all(@rows) < $!row-count;
    Math::Matrix.new([ @rows.map( { [ @!rows[$_][|@cols] ] } ) ]);
}

method equal(Math::Matrix:D: Math::Matrix $b --> Bool) {
    @!rows ~~ $b!rows;
}

method size(Math::Matrix:D: ){
    return $!row-count, $!column-count;
}

method !build_is-square(Math::Matrix:D: --> Bool) {
    $!column-count == $!row-count;
}

method !build_is-invertible(Math::Matrix:D: --> Bool) {
    self.is-square and self.determinant != 0;
}

method !build_is-zero(Math::Matrix:D: --> Bool) {
    self.density() == 0;
}

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

method !build_is-orthogonal(Math::Matrix:D: --> Bool) {
    return False unless self.is-square;
    self.dotProduct( self.T ) ~~ Math::Matrix.new-identity( $!row-count );
}


method !build_is-positive-definite (Math::Matrix:D: --> Bool) { # with Sylvester's criterion
    return False unless self.is-square;
    return False unless self.determinant > 0;
    my $sub = Math::Matrix.new( @!rows );
    for $!row-count - 1 ... 1 -> $r {
        $sub = $sub.submatrix($r,$r);
        return False unless $sub.determinant > 0;
    }
    True;
}

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
    my @inverted = self!identity_array( $!row-count );
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

multi method dotProduct(Math::Matrix:D: Math::Matrix $b --> Math::Matrix:D ) {
    my @product;
    die "Number of columns of the second matrix is different from number of rows of the first operand" unless $!column-count == $b!row-count;
    for ^$!row-count X ^$b!column-count -> ($r, $c) {
        @product[$r][$c] += @!rows[$r][$_] * $b!rows[$_][$c] for ^$b!row-count;
    }
    Math::Matrix.new( @product );
}

multi method multiply(Math::Matrix:D: Real $r --> Math::Matrix:D ) {
    self.apply( * * $r );
}

method apply(Math::Matrix:D: &coderef --> Math::Matrix:D ) {
    Math::Matrix.new( [ @!rows.map: {
            [ $_.map( &coderef ) ]
    } ] );
}

method negative(Math::Matrix:D: --> Math::Matrix:D ) {
    self.apply( - * );
}

method add(Math::Matrix:D: Math::Matrix $b where { $!row-count == $b!row-count and $!column-count == $b!column-count } --> Math::Matrix:D ) {
    my @sum;
    for ^$!row-count X ^$!column-count -> ($r, $c) {
        @sum[$r][$c] = @!rows[$r][$c] + $b!rows[$r][$c];
    }
    Math::Matrix.new( @sum );
}

method subtract(Math::Matrix:D: Math::Matrix $b where { $!row-count == $b!row-count and $!column-count == $b!column-count } --> Math::Matrix:D ) {
    my @subtract;
    for ^$!row-count X ^$!column-count -> ($r, $c) {
        @subtract[$r][$c] = @!rows[$r][$c] - $b!rows[$r][$c];
    }
    Math::Matrix.new( @subtract );
}

multi method multiply(Math::Matrix:D: Math::Matrix $b where { $!row-count == $b!row-count and $!column-count == $b!column-count } --> Math::Matrix:D ) {
    my @multiply;
    for ^$!row-count X ^$!column-count -> ($r, $c) {
        @multiply[$r][$c] = @!rows[$r][$c] * $b!rows[$r][$c];
    }
    Math::Matrix.new( @multiply );
}

method det(Math::Matrix:D: --> Numeric )        { self.determinant }  # the usual short name
method !build_determinant(Math::Matrix:D: --> Numeric) {
    fail "Number of columns has to be same as number of rows" unless self.is-square;
    return 1            if $!row-count == 0;
    return @!rows[0][0] if $!row-count == 1;
    if $!row-count > 4 {
        #up to 4x4 naive method is fully usable
        return [*]($.diagonal) if $.is-upper-triangular || $.is-lower-triangular;
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

sub insert ($x, @xs) { ([flat @xs[0 ..^ $_], $x, @xs[$_ .. *]] for 0 .. @xs) }
sub order ($sg, @xs) { $sg > 0 ?? @xs !! @xs.reverse }
multi σ_permutations ([]) { [] => 1 }
multi σ_permutations ([$x, *@xs]) {
    σ_permutations(@xs).map({ |order($_.value, insert($x, $_.key)) }) Z=> |(1,-1) xx *
}

method !build_trace(Math::Matrix:D: --> Numeric) {
    [+] self.diagonal;
}

method !build_density(Math::Matrix:D: --> Rat) {
    my $valcount = 0;
    for ^$!row-count X ^$!column-count -> ($r, $c) { $valcount++ if @!rows[$r][$c] != 0 }
    $valcount / ($!row-count * $!column-count);
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

multi method norm(Math::Matrix:D: Str $which where * eq 'rowsum' --> Numeric) {
    max map {[+] map {abs $_}, @$_}, @!rows;
}

multi method norm(Math::Matrix:D: Str $which where * eq 'columnsum' --> Numeric) {
    max map {my $c = $_; [+](map {abs $_[$c]}, @!rows) }, ^$!column-count;
}

multi method norm(Math::Matrix:D: Str $which where * eq 'max' --> Numeric) {
    max map {max map {abs $_},  @$_}, @!rows;
}

multi method condition(Math::Matrix:D: --> Numeric) {
    self.norm() * self.inverted().norm();
}

method decompositionLUCrout(Math::Matrix:D: ) {
    fail "Not square matrix" unless self.is-square;
    my $sum;
    my $size = self!row-count;
    my $U = self!identity_array( $size );
    my $L = self!zero_array( $size );

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

# LU factorization with optional partial pivoting and optional diagonal matrix
multi method decompositionLU(Math::Matrix:D: Bool :$pivot = True, :$diagonal = False) {
    fail "Not an square matrix" unless self.is-square;
    fail "Has to be invertible when not using pivoting" if not $pivot and not self.is-invertible;
    my $size = self!row-count;
    my @L = self!identity_array( $size );
    my @U = self!clone_rows( );
    my @P = self!identity_array( $size );
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

multi sub infix:<⋅>( Math::Matrix $a, Math::Matrix $b where { $a!column-count == $b!row-count} --> Math::Matrix:D ) is looser(&infix:<*>) is export {
    $a.dotProduct( $b );
}

multi sub infix:<dot>(Math::Matrix $a, Math::Matrix $b --> Math::Matrix:D ) is looser(&infix:<*>) is export {
    $a ⋅ $b;
}

multi sub infix:<*>(Math::Matrix $a, Real $r --> Math::Matrix:D ) is export {
    $a.multiply( $r );
}

multi sub infix:<*>(Real $r, Math::Matrix $a --> Math::Matrix:D ) is export {
    $a.multiply( $r );
}

multi sub infix:<*>(Math::Matrix $a, Math::Matrix $b  where { $a!row-count == $b!row-count and $a!column-count == $b!column-count} --> Math::Matrix:D ) is export {
    $a.multiply( $b );
}

multi sub infix:<+>(Math::Matrix $a, Math::Matrix $b --> Math::Matrix:D ) is export {
    $a.add($b);
}

multi sub infix:<->(Math::Matrix $a, Math::Matrix $b --> Math::Matrix:D ) is export {
    $a.subtract($b);
}

multi sub infix:<**>(Math::Matrix $a where { $a.is-square }, Int $e --> Math::Matrix:D ) is export {
    return Math::Matrix.new-identity( $a!row-count ) if $e ==  0;
    my $p = $a.clone;
    $p = $p.dotProduct( $a ) for 2 .. abs $e;
    $p = $p.inverted         if  $e < 0;
    $p;
}

multi sub circumfix:<|| ||>(Math::Matrix $a --> Numeric) is equiv(&prefix:<!>) is export {
    $a.norm();
}



=begin pod
=head1 NAME
Math::Matrix - Simple Matrix mathematics
=head1 SYNOPSIS

Matrix stuff, transposition, dot Product, and so on

=head1 DESCRIPTION

Perl6 already provide a lot of tools to work with array, shaped array, and so on,
however, even hyper operators does not seem to be enough to do matrix calculation
Purpose of that library is to propose some tools for Matrix calculation.

I should probably use shaped array for the implementation, but i am encountering
some issues for now. Problem being it might break the syntax for creation of a Matrix,
use with consideration...

=head1 METHODS

=head2 method new
    method new( [[1,2],[3,4]])

   A constructor, takes parameters like:
=item rows : an array of row, each row being an array of cells

   Number of cells per row must be identical

=head2 method new-identity

    my $matrix = Math::Matrix.new-identity( 3 );
    This method is a constructor that returns an identity matrix of the size given in parameter
    All the cells are set to 0 except the top/left to bottom/right diagonale, set to 1

=head2 method new-zero

    my $matrix = Math::Matrix.new-zero( 3, 4 );
    This method is a constructor that returns an zero matrix of the size given in parameter.
    If only one parameter is given, the matrix is quadratic. All the cells are set to 0.

=head2 method new-diagonal

    my $matrix = Math::Matrix.new-diagonal( 2, 4, 5 );
    This method is a constructor that returns an diagonal matrix of the size given
    by count of the parameter.
    All the cells are set to 0 except the top/left to bottom/right diagonal,
    set to given values.

=head2 method new-vector-product

    my $matrixp = Math::Matrix.new-vector-product([1,2,3],[2,3,4]);
    my $matrix = Math::Matrix.new([2,3,4],[4,6,8],[6,9,12]);       # same matrix

    This method is a constructor that returns a matrix which is a result of 
    the matrix product (method dotProduct, or operator dot) of a column vector
    (first argument) and a row vector (second argument).

=head2 method equal

    if $matrixa.equal( $matrixb ) {
    if $matrixa ~~ $matrixb {

    Checks two matrices for Equality

=head2 method size

    List of two values: number of rows and number of columns.

    say $matrix.size();
    my $dim = min $matrix.size();  

=head2 method density

    say 'this is a fully (occupied) matrix' if $matrix.density() == 1;

    percentage of cells which hold a value different than 0

=head2 method is-square

    if $matrix.is-square {

    Tells if number of rows and colums are the same

=head2 method is-zero

   True if every cell has value of 0.

=head2 method is-identity

   True if every cell on the diagonal (where row index equals column index) is 1
   and any other cell is 0.

=head2 method is-diagonal

   True if only cell on the diagonal differ from 0.

=head2 method is-diagonally-dominant

   True if cells on the diagonal have a bigger or equal absolute value than the
   sum of the other absolute values in the column.

   if $matrix.is-diagonally-dominant {
   $matrix.is-diagonally-dominant(:!strict)   # same thing (default)
   $matrix.is-diagonally-dominant(:strict)    # diagonal elements (DE) are stricly greater (>)
   $matrix.is-diagonally-dominant(:!strict, :along<column>) # default
   $matrix.is-diagonally-dominant(:strict,  :along<row>)    # DE > sum of rest row
   $matrix.is-diagonally-dominant(:!strict, :along<both>)   # DE >= sum of rest row and rest column

=head2 method is-upper-triangular

   True if every cell below the diagonal (where row index is greater than column index) is 0.

=head2 method is-lower-triangular

   True if every cell above the diagonal (where row index is smaller than column index) is 0.

=head2 method is-symmetric

    if $matrix.is-symmetric {

    Is True if every cell with coordinates x y has same value as the cell on y x.

=head2 method is-positive-definite

    True if all main minors are positive

=head2 method is-orthogonal

    if $matrix.is-orthogonal {

    Is True if the matrix multiplied (dotProduct) with its transposed version (T)
    is an identity matrix.

=head2 method is-invertible

    Is True if number of rows and colums are the same and determinant is not zero.

=head2 method transposed, alias T

    return a new Matrix, which is the transposition of the current one

=head2 method inverted

    return a new Matrix, which is the inverted of the current one

=head2 method dotProduct

    my $product = $matrix1.dotProduct( $matrix2 )
    return a new Matrix, result of the dotProduct of the current matrix with matrix2
    Call be called throug operator ⋅ or dot , like following:
    my $c = $a ⋅ $b ;
    my $c = $a dot $b ;

    A shortcut for multiplication is the power - operator **
    my $c = $a **  3;      # same as $a dot $a dot $a
    my $c = $a ** -3;      # same as ($a dot $a dot $a).inverted
    my $c = $a **  0;      # created an right sized identity matrix

    Matrix can be multiplied by a Real as well, and with operator *
    my $c = $a.multiply( 2.5 );
    my $c = 2.5 * $a;
    my $c = $a * 2.5;

=head2 method apply

    my $new = $matrix.apply( * + 2 );
    return a new matrix which is the current one with the function given in parameter applied to every cells

=head2 method negative

    my $new = $matrix.negative();
    return the negative of a matrix

=head2 method add

    my $new = $matrix.add( $matrix2 );
    Return addition of 2 matrices of the same size, can use operator +
    $new = $matrix + $matrix2;

=head2 method subtract

    my $new = $matrix.subtract( $matrix2 );
    Return substraction of 2 matrices of the same size, can use operator -
    $new = $matrix - $matrix2;

=head2 method multiply

    my $new = $matrix.multiply( $matrix2 );
    Return multiply of elements of 2 matrices of the same size, can use operator *
    $new = $matrix * $matrix2;

=head2 method determinant

    my $det = $matrix.determinant( );
    Calculate the determinant of a square matrix

=head2 method trace

    my $tr = $matrix.trace( );
    Calculate the trace of a square matrix

=head2 method rank

    my $r = $matrix.rank( );
    rank is the number of independent row or column vectors
    or also called independent dimensions
    (thats why this command is sometimes calles dim)

=head2 method kernel

    my $tr = $matrix.kernel( );
    kernel of matrix, number of dependent rows or columns

=head2 method norm

    my $norm = $matrix.norm( );          # euclidian norm (L2, p = 2)
    my $norm = ||$matrix||;              # operator shortcut to do the same
    my $norm = $matrix.norm(1);          # p-norm, L1 = sum of all cells
    my $norm = $matrix.norm(p:<4>,q:<3>);# p,q - norm, p = 4, q = 3
    my $norm = $matrix.norm(p:<2>,q:<2>);# Frobenius norm
    my $norm = $matrix.norm('max');      # max norm - biggest absolute value of a cell
    $matrix.norm('rowsum');              # row sum norm - biggest abs. value-sum of a row
    $matrix.norm('columnsum');           # column sum norm - same column wise

=head2 method decompositionLU

    my ($L, $U, $P) = $matrix.decompositionLU( );
    $L dot $U eq $matrix dot $P;         # True
    my ($L, $U) = $matrix.decompositionLUC(:!pivot);
    $L dot $U eq $matrix;                # True

    $L is a left triangular matrix and $R is a right one
    Without pivotisation the marix has to be invertible (square and full ranked).
    In case you whant two unipotent triangular matrices and a diagonal (D):
    use the :diagonal option, which can be freely combined with :pivot.

    my ($L, $D, $U, $P) = $matrix.decompositionLU( :diagonal );
    $L dot $D dot $U eq $matrix dot $P;  # True

=head2 method decompositionLUCrout

    my ($L, $U) = $matrix.decompositionLUCrout( );
    $L dot $U eq $matrix;                # True

    $L is a left triangular matrix and $R is a right one
    This decomposition works only on invertible matrices (square and full ranked).

=head2 method decompositionCholesky

    my $D = $matrix.decompositionCholesky( );
    $D dot $D.T eq $matrix;              # True 

    $D is a left triangular matrix
    This decomposition works only on symmetric and definite positive matrices.

=end pod
