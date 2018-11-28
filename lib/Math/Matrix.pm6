use v6.c;
need Math::Matrix::Util;

unit class Math::Matrix:ver<0.3.8>:auth<github:pierre-vigier> does Math::Matrix::Util;
use AttrX::Lazy;

################################################################################
# attributes
################################################################################

has @!rows is required; # primary content

has Int $!row-count;
has Int $!column-count;

has Bool $!is-square is lazy;
has Bool $!is-zero is lazy;
has Bool $!is-main-diagonal-zero is lazy;
has Bool $!is-identity is lazy;
has Bool $!is-diagonal is lazy;
has Bool $!is-diagonal-constant is lazy;
has Bool $!is-catalecticant is lazy;
has Bool $!is-symmetric is lazy;
has Bool $!is-antisymmetric is lazy;
has Bool $!is-self-adjoint is lazy;
has Bool $!is-unitary is lazy;
has Bool $!is-orthogonal is lazy;
has Bool $!is-invertible is lazy;
has Bool $!is-positive-definite is lazy;
has Bool $!is-positive-semidefinite is lazy;

has Int     $!upper-bandwith is lazy;
has Int     $!lower-bandwith is lazy;
has Int     $!rank is lazy;
has Int     $!nullity is lazy;
has Rat     $!density is lazy;
has Numeric $!trace is lazy;
has Numeric $!determinant is lazy;
has Numeric $!condition is lazy;
has Numeric $!narrowest-element-type is lazy;
has Numeric $!widest-element-type is lazy;

has Str     $!gist;

################################################################################
# types
################################################################################

subset PosInt of Int where * > 0;
subset NumList of List where { .all ~~ Numeric };
subset NumArray of Array where { .all ~~ Numeric };

################################################################################
# private accessors
################################################################################

method !rows       { @!rows }
method !clone-cells  { self!AoA-clone(@!rows) }
method !row-count    { $!row-count }
method !column-count  { $!column-count }

################################################################################
# public methods: constructors
################################################################################

multi method new( @m ) {
    self!check-matrix-data( @m );
    self.bless( rows => @m );
}
multi method new (Str $m){
    my @m = $m.lines.map: { .words.map: {.Bool.Str eq $_ ?? .Bool !! .Numeric} };
    self!check-matrix-data( @m );
    self.bless( rows => @m );
}

submethod BUILD( :@rows!, :$density, :$trace, :$determinant, :$rank, :$nullity, :$is-zero, :$is-identity, :$is-symmetric) {
    @!rows         = self!AoA-clone(@rows);
    $!row-count    = @rows.elems;
    $!column-count = @rows[0].elems;
    $!density      = $density if $density.defined;
    $!trace        = $trace if $trace.defined;
    $!determinant  = $determinant if $determinant.defined;
    $!rank         = $rank if $rank.defined;
    $!nullity      = $nullity if $nullity.defined;
    $!is-zero      = $is-zero if $is-zero.defined;
    $!is-identity  = $is-identity if $is-identity.defined;
    $!is-symmetric = $is-symmetric if $is-symmetric.defined;
}

method clone { self.bless( rows => @!rows ) }

multi method new-zero(PosInt $size) {
    self.bless( rows => self!zero-array($size, $size),
            determinant => 0, rank => 0, nullity => $size, density => 0.0, trace => 0,
            is-zero => True, is-identity => False, is-diagonal => True, 
            is-square => True, is-symmetric => True );
}
multi method new-zero(Math::Matrix:U: PosInt $rows, PosInt $cols) {
    self.bless( rows => self!zero-array($rows, $cols),
            determinant => 0, rank => 0, nullity => min($rows, $cols), density => 0.0, trace => 0,
            is-zero => True, is-identity => False, is-diagonal => ($cols == $rows),  );
}

method new-identity( Int $size where * > 0 ) {
    self.bless( rows => self!identity-array($size),  
                determinant => 1, rank => $size, nullity => 0, density => 1/$size, trace => $size,
                is-zero => False, is-identity => True, 
                is-square => True, is-diagonal => True, is-symmetric => True );
}

method new-diagonal( *@diag ){
    fail "Expect at least on number as parameter" if @diag == 0;
    fail "Expect an List of Number" unless @diag ~~ NumList;
    my Int $size = +@diag;
    my @d = self!zero-array($size, $size);
    (^$size).map: { @d[$_][$_] = @diag[$_] };

    self.bless( rows => @d, determinant => [*](@diag.flat), trace => [+] (@diag.flat),
                is-square => True, is-diagonal => True, is-symmetric => True  );
}

method new-lower-triangular( @m ) {
    #don't want to trust outside of the class that a matrix is really triangular
    self.bless( rows => @m );
}

method new-upper-triangular( @m ) {
    #don't want to trust outside of the class that a matrix is really triangular
    self.bless( rows => @m );
}

method new-vector-product (@column_vector, @row_vector){
    fail "Expect two Arrays of Number" unless @column_vector ~~ NumArray and @row_vector ~~ NumArray;
    my @p;
    for ^+@column_vector X ^+@row_vector -> ($r, $c) { 
        @p[$r][$c] = @column_vector[$r] * @row_vector[$c] 
    }
    self.bless( rows => @p, determinant => 0 , rank => 1 );
}

################################################################################
# end of constructor - start accessors
################################################################################

method element(Math::Matrix:D: Int:D $row, Int:D $column --> Numeric ) {
    self!check-index($row, $column);
    @!rows[$row][$column];
}

multi method AT-POS (Math::Matrix:D: Int:D $row){
    self!check-row-index($row);
    @!rows[$row];
}

method row(Math::Matrix:D: Int:D $row  --> List) {
    self!check-row-index($row);
    @!rows[$row];
}

method column(Math::Matrix:D: Int:D $column --> List) {
    self!check-column-index($column);
    (@!rows.keys.map:{ @!rows[$_;$column] }).list;
}

method diagonal(Math::Matrix:D: $start? = 0 --> List){
    fail "requested diagonal is outside of matrix boundaries" if $start >= $!row-count or $start <= -$!column-count;
    ($start > 0 ?? map { @!rows[$^i+$start;$^i] }, ^min($!column-count, $!row-count - $start)
                !! map { @!rows[$^i;$^i-$start] }, ^min($!row-count, $!column-count + $start) ).list;
}

method skew-diagonal(Math::Matrix:D: $start? = 0 --> List){
    fail "skew diagonal is only defined for square matrices" unless $.is-square;
    fail "requested skew diagonal is outside of matrix boundaries" if $start.abs >= $!row-count;
    ($start > 0 ?? map { @!rows[$!row-count -1 -$^i; $start+$^i] }, ^($!row-count - $start)
                !! map { @!rows[$!row-count -1 -$^i +$start;$^i] }, ^($!row-count + $start) ).list;
}

multi method submatrix(Math::Matrix:D: Int:D $row, Int:D $column --> Math::Matrix:D ){
    self!check-index($row, $column);
    my @rows = ^$!row-count;     @rows.splice($row,1);
    my @cols = ^$!column-count;  @cols.splice($column,1);
    self.submatrix( rows => @rows , columns => @cols);
}
multi method submatrix(Math::Matrix:D: :@rows    = (^$!row-count).list,
                                       :@columns = (^$!column-count).list --> Math::Matrix:D) {
    my @r = @rows.max    == Inf ?? (@rows.min    .. $!row-count-1).list    !! @rows.list;
    my @c = @columns.max == Inf ?? (@columns.min .. $!column-count-1).list !! @columns.list;
    fail "Need at least one row number" if @r == 0;
    fail "Need at least one column number" if @c == 0;
    self!check-indices(@r, @c);
    Math::Matrix.new([ @r.map( { [ @!rows[$^row][|@c] ] } ) ]);
}

################################################################################
# end of accessors - start with type conversion and handy shortcuts
################################################################################

method Bool(        Math::Matrix:D: --> Bool)   { ! self.is-zero }
method Numeric (    Math::Matrix:D: --> Numeric){   self.norm   }
method Str(         Math::Matrix:D: --> Str)    {   join("\n", @!rows.map: *.Str) }
method Range(       Math::Matrix:D: --> Range)  {   self.list.minmax }
method Array(       Math::Matrix:D: --> Array)  {   self!clone-cells }
method list(        Math::Matrix:D: --> List)   {   self.list-rows.flat.list }
method list-rows(   Math::Matrix:D: --> List)   {  (@!rows.map: {.flat}).list }
method list-columns(Math::Matrix:D: --> List)   {  ((^$!column-count).map: {self.column($_)}).list }
method Hash(        Math::Matrix:D: --> Hash)   {  ((^$!row-count).map: {$_ => @!rows[$_].kv.Hash}).Hash}

multi method gist(Math::Matrix:U: --> Str) { "({self.^name})" }
multi method gist(Math::Matrix:D: Int :$max-chars?, Int :$max-rows? --> Str) {
    if not $!gist.defined or ($max-chars.defined or $max-rows.defined) {
        my $max-width = (not $max-chars.defined or $max-chars < 5) ?? 80 !! $max-chars;
        my $max-heigth = (not $max-rows.defined or $max-rows < 2) ?? 20 !! $max-rows;
        my @fmt-content = @!rows.map: {    # all values in optimized complex format
            (.map: { $_ ~~ Bool   ?? %( re => $_,             im => '' ) !! 
                    $_ ~~ Complex ?? %( re => $_.re.fmt("%g"),im => (($_.im >= 0 ??'+'!!'')~$_.im.fmt("%g")~'i') ) !!
                                     %( re => $_.fmt("%g"),   im => '' )
        }).Array};
        my @col-width;                     # width of the formatted element content in n column
        @fmt-content.map: {
            for .kv -> $ci, $val {
                @col-width[$ci]<re>.push: $val<re>.chars;
                @col-width[$ci]<im>.push: $val<im>.chars;
        }};
        my @max-width = @col-width.map: { %( re => $_<re>.max, im => $_<im>.max ) };
        my ($shown-cols, $width-index);
        for @max-width.kv -> $ci, $max {
            $width-index += 2 + $max<re> + $max<im>;
            if ($ci < @max-width.end and $width-index <= $max-width-3) 
            or $width-index <= $max-width {$shown-cols++}
            else                          {last}
        }
        my $shown-rows = min @!rows.elems, $max-heigth;
        my $out;
        for @fmt-content.kv -> $ri, $row {
            if $ri == $shown-rows {$out ~= "  ...\n" ; last}
            for $row.kv -> $ci, $val {
                if $ci == $shown-cols { $out ~= ' ..' ; last}
                $out ~= (' ' x (@max-width[$ci]<re> - @col-width[$ci]<re>[$ri]) + 2) ~ $val<re> ~ 
                        $val<im> ~ (' ' x (@max-width[$ci]<im> - @col-width[$ci]<im>[$ri]));
            }
            $out ~= "\n";
        };
        $!gist = $out.chomp;
    }
    $!gist;
}

multi method perl(Math::Matrix:D: --> Str){ self.WHAT.perl ~ ".new(" ~ @!rows.perl ~ ")" }

################################################################################
# end of type conversion and handy shortcuts - start boolean matrix properties
################################################################################

method !build_is-square( Math::Matrix:D: --> Bool)        { $!column-count == $!row-count }
method !build_is-zero(    Math::Matrix:D: --> Bool)        { self.density() == 0 }
method !build_is-identity( Math::Matrix:D: --> Bool)        { $.is-diagonal and [==](($.diagonal.flat,1).flat)}
method !build_is-main-diagonal-zero(Math::Matrix:D: --> Bool){ [==](($.diagonal.flat,0).flat) }

method is-triangular(Math::Matrix:D: --> Bool) {
    $.is-square and ($.lower-bandwith == 0 or $.upper-bandwith == 0) 
}
method is-upper-triangular(Math::Matrix:D: Bool :$strict = False --> Bool) {
    $.is-square and $.lower-bandwith == 0 and (!$strict or $.is-main-diagonal-zero)
}
method is-lower-triangular( Math::Matrix:D: Bool :$strict = False --> Bool) {
    $.is-square and $.upper-bandwith == 0 and (!$strict or $.is-main-diagonal-zero)
}

method !build_is-diagonal( Math::Matrix:D: --> Bool) {
    self.is-square and $.lower-bandwith == 0 and $.upper-bandwith == 0;
}

method !build_is-diagonal-constant( Math::Matrix:D: --> Bool) {
    [&&](map { [==] $.diagonal($_).list }, -$!column-count+1 .. $!row-count-1);
}
method !build_is-catalecticant( Math::Matrix:D: --> Bool) {
    $.is-square and [&&](map { [==] $.skew-diagonal($_).list }, -$!column-count+1 .. $!row-count-1);
}

method is-diagonally-dominant( Math::Matrix:D: Bool :$strict = False, 
                              Str :$along where {$^orient eq any <column row both>} = 'column' --> Bool) {
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

method !build_is-symmetric( Math::Matrix:D: --> Bool) {
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
    self.is-square and self.T.conj ~~ self
}

method !build_is-unitary(Math::Matrix:D: --> Bool) {
    self.is-square and self.dot-product( self.T.conj ) ~~ Math::Matrix.new-identity( $!row-count );
}

method !build_is-orthogonal(Math::Matrix:D: --> Bool) {
    self.is-square and self.dot-product( self.T ) ~~ Math::Matrix.new-identity( $!row-count );
}

method !build_is-invertible(Math::Matrix:D: --> Bool) {
    self.is-square and self.determinant != 0;
}

method !build_is-positive-definite (Math::Matrix:D: --> Bool) { # with Sylvester's criterion
    return False unless self.is-square;
    return False unless self.determinant > 0;
    my $sub = Math::Matrix.new( @!rows );
    for $!row-count - 1 ... 1 -> $r {
        $sub = $sub.submatrix(rows => 0..$r, columns => 0..$r);
        return False unless $sub.determinant > 0;
    }
    True;
}
method !build_is-positive-semidefinite (Math::Matrix:D: --> Bool) { # with Sylvester's criterion
    return False unless self.is-square;
    return False unless self.determinant >= 0;
    my $sub = Math::Matrix.new( @!rows );
    for $!row-count - 1 ... 1 -> $r {
        $sub = $sub.submatrix(rows => 0..$r, columns => 0..$r);
        return False unless $sub.determinant >= 0;
    }
    True;
}

################################################################################
# end of boolean matrix properties - start numeric matrix properties
################################################################################

method size(Math::Matrix:D: --> List)          {  $!row-count, $!column-count }

method !build_density(Math::Matrix:D: --> Rat) {
    my $valcount = 0;
    for ^$!row-count X ^$!column-count -> ($r, $c) { $valcount++ if @!rows[$r][$c] != 0 }
    $valcount / self.elems;
}

method !build_upper-bandwith(Math::Matrix:D: --> Int) {
    for $!column-count-1 ... 1  -> $i {
        return $i unless [&&](map * == 0, $.diagonal(-$i).list)
    }
    0;
}
method !build_lower-bandwith(Math::Matrix:D: --> Int) {
    for $!row-count-1 ... 1  -> $i {
        return $i unless [&&](map * == 0, $.diagonal($i).list)
    }   
    0;
}
method bandwith(Math::Matrix:D: Str $which = '' --> Int) { max $.upper-bandwith, $.lower-bandwith }

method !build_trace(Math::Matrix:D: --> Numeric) {
    fail "trace is only defined for a square matrix" unless self.is-square;
    self.diagonal.sum;
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
method !build_nullity(Math::Matrix:D: --> Int) {
    min(self.size) - self.rank;
}

method det(Math::Matrix:D: --> Numeric )        { self.determinant }  # the usual short name
method !build_determinant(Math::Matrix:D: --> Numeric) {
    fail "number of columns has to be same as number of rows" unless self.is-square;
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
sub insert ($x, @xs) { ([flat @xs[0 ..^ $_], $x, @xs[$_ .. *]] for 0 .. @xs) }
sub order ($sg, @xs) { $sg > 0 ?? @xs !! @xs.reverse }

multi sub σ_permutations ([]) { [] => 1 }
multi sub σ_permutations ([$x, *@xs]) {
    σ_permutations(@xs).map({ |order($_.value, insert($x, $_.key)) }) Z=> |(1,-1) xx *
}

method minor(Math::Matrix:D: Int:D $row, Int:D $col --> Numeric) { $.submatrix($row, $col).determinant }

multi method norm(Math::Matrix:D: PosInt :$p = 2, PosInt :$q = $p --> Numeric) {
    my $norm = 0;
    for ^$!column-count -> $c {
        my $col_sum = 0;
        for ^$!row-count -> $r {  $col_sum += abs(@!rows[$r][$c]) ** $p }
        $norm += $col_sum ** ($q / $p);
    }
    $norm ** (1/$q);
}
multi method norm(Math::Matrix:D: PosInt $p   --> Numeric){ self.norm(:p<$p>,:q<$p>)}
multi method norm(Math::Matrix:D: 'frobenius' --> Numeric){ self.norm(:p<2>, :q<2>)}
multi method norm(Math::Matrix:D: 'euclidean' --> Numeric){ self.norm(:p<2>, :q<2>)}

multi method norm(Math::Matrix:D: 'max' --> Numeric)      { max            @!rows.map: {max .map: *.abs} }
multi method norm(Math::Matrix:D: 'row-sum' --> Numeric)  { max            @!rows.map: {[+] .map: *.abs} }
multi method norm(Math::Matrix:D: 'column-sum'--> Numeric){ max (^$!column-count).map: {[+] self.column($_).map: *.abs} }

method !build_condition(Math::Matrix:D:              --> Numeric) { $.norm() * $.inverted.norm       }

method !build_narrowest-element-type(Math::Matrix:D: --> Numeric){
    return Bool if any( @!rows[*;*] ) ~~ Bool;
    return Int  if any( @!rows[*;*] ) ~~ Int;
    return Num  if any( @!rows[*;*] ) ~~ Num;
    return Rat  if any( @!rows[*;*] ) ~~ Rat;
    return FatRat if any( @!rows[*;*] ) ~~ FatRat;
    Complex;
}
method !build_widest-element-type(Math::Matrix:D: --> Numeric){
    return Complex if any( @!rows[*;*] ) ~~ Complex;
    return FatRat if any( @!rows[*;*] ) ~~ FatRat;
    return Rat   if any( @!rows[*;*] ) ~~ Rat;
    return Num  if any( @!rows[*;*] ) ~~ Num;
    return Int if any( @!rows[*;*] ) ~~ Int;
    Bool;
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

method negated(Math::Matrix:D: --> Math::Matrix:D )       { self.map( - * ) }

method conj(Math::Matrix:D: --> Math::Matrix:D  )         { self.conjugated }
method conjugated(Math::Matrix:D: --> Math::Matrix:D )    { self.map( { $_.conj} ) }

method adjugated(Math::Matrix:D: --> Math::Matrix:D) {
    fail "Number of columns has to be same as number of rows" unless self.is-square;
    $!row-count == 1 ?? self.new([[1]]) 
                     !! self.map-index({ self.minor($^m, $^n) * self.cofactor-sign($^m, $^n) });
}

method inverted(Math::Matrix:D: --> Math::Matrix:D) {
    fail "Number of columns has to be same as number of rows" unless self.is-square;
    fail "Matrix is not invertible, or singular because defect (determinant = 0)" if self.determinant == 0;
    my @clone = self!clone-cells();
    my @inverted = self!identity-array( $!row-count );
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

method rref(                    Math::Matrix:D: --> Math::Matrix:D) { self.reduced-row-echelon-form }
method reduced-row-echelon-form(Math::Matrix:D: --> Math::Matrix:D) {
    my @ref = self!clone-cells();
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

################################################################################
# end of derivative matrices - start decompositions
################################################################################

# LU factorization with optional partial pivoting and optional diagonal matrix
method decompositionLU(Math::Matrix:D: Bool :$pivot = True, :$diagonal = False) {
    fail "Not an square matrix" unless self.is-square;
    fail "Has to be invertible when not using pivoting" if not $pivot and not self.is-invertible;
    my $size = $!row-count;
    my @L = self!identity-array( $size );
    my @U = self!clone-cells( );
    my @P = self!identity-array( $size );

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
        $pivot ?? (Math::Matrix.new-lower-triangular(@L), Math::Matrix.new-diagonal(@D), 
                   Math::Matrix.new-upper-triangular(@U), Math::Matrix.new(@P))
               !! (Math::Matrix.new-lower-triangular(@L), Math::Matrix.new-diagonal(@D),
                   Math::Matrix.new-upper-triangular(@U));
    }
    $pivot ?? (Math::Matrix.new-lower-triangular(@L), Math::Matrix.new-upper-triangular(@U), Math::Matrix.new(@P))
           !! (Math::Matrix.new-lower-triangular(@L), Math::Matrix.new-upper-triangular(@U));
}

method decompositionLUCrout(Math::Matrix:D: ) {
    fail "Not square matrix" unless self.is-square;
    my $sum;
    my $size = $!row-count;
    my $U = self!identity-array( $size );
    my $L = self!zero-array( $size );

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
    my @D = self!clone-cells();
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
    return Math::Matrix.new-lower-triangular( @D );
}

################################################################################
# end of decompositions - start matrix math operations
################################################################################


method equal(Math::Matrix:D: Math::Matrix $b --> Bool)           { @!rows ~~ $b!rows }
multi method ACCEPTS(Math::Matrix:D: Math::Matrix:D $b --> Bool) { self.equal( $b )  }


# add matrix
multi method add(Math::Matrix:D: Str $b --> Math::Matrix:D ) { self.add( Math::Matrix.new( $b ) ) }
multi method add(Math::Matrix:D:     @b --> Math::Matrix:D ) { self.add( Math::Matrix.new( @b ) ) }
multi method add(Math::Matrix:D: Math::Matrix $b where {self.size eqv $b.size} --> Math::Matrix:D ) {
    my @sum;
    for ^$!row-count X ^$!column-count -> ($r, $c) {
        @sum[$r][$c] = @!rows[$r][$c] + $b!rows[$r][$c];
    }
    Math::Matrix.new( @sum );
}
# add vector
multi method add(Math::Matrix:D: @v where {@v.all ~~ Numeric}, Int :$row! --> Math::Matrix:D) {
    fail "Matrix has $!column-count columns, but got "~ +@v ~ "element row." unless $!column-count == +@v;
    self!check-row-index($row);
    my @m = self!clone-cells;
    @m[$row] = @m[$row] <<+>> @v;
    Math::Matrix.new( @m );
}
multi method add(Math::Matrix:D: @v where {@v.all ~~ Numeric}, Int :$column! --> Math::Matrix:D ) {
    self!check-column-index($column);
    fail "Matrix has $!row-count rows, but got "~ +@v ~ "element column." unless $!row-count == +@v;
    my @m = self!clone-cells;
    @v.keys.map:{ @m[$_][$column] += @v[$_] };
    Math::Matrix.new( @m );
}
# add scalar
multi method add(Math::Matrix:D: Numeric $s, --> Math::Matrix:D )                          { self.map( *  + $s  ) }
multi method add(Math::Matrix:D: Numeric $s, Int :$row!, Int :$column --> Math::Matrix:D ) {
    self!check-row-index($row)       if $row.defined;
    self!check-column-index($column) if $column.defined;
    self.map(rows  => $row.defined ?? ($row..$row) !! ^$!row-count, 
             columns => $column.defined ?? ($column..$column) !! ^$!column-count, { $_ + $s } );
}


multi method multiply(Math::Matrix:D: Str $b --> Math::Matrix:D ) { self.multiply( Math::Matrix.new( $b ) ) }
multi method multiply(Math::Matrix:D:     @b --> Math::Matrix:D ) { self.multiply( Math::Matrix.new( @b ) ) }
multi method multiply(Math::Matrix:D: Math::Matrix $b where {self.size eqv $b.size} --> Math::Matrix:D ) {
    my @product;
    for ^$!row-count X ^$!column-count -> ($r, $c) {
        @product[$r][$c] = @!rows[$r][$c] * $b!rows[$r][$c];
    }
    Math::Matrix.new( @product );
}
multi method multiply(Math::Matrix:D: Numeric $f --> Math::Matrix:D )                          { self.map( *  * $f  ) }
multi method multiply(Math::Matrix:D: Numeric $f, Int :$row, Int :$column --> Math::Matrix:D ) {
    self!check-row-index($row)       if $row.defined;
    self!check-column-index($column) if $column.defined;
    self.map(rows  => $row.defined ?? ($row..$row) !! ^$!row-count,
             columns => $column.defined ?? ($column..$column) !! ^$!column-count, { $_ * $f } );
}

method dot-product(Math::Matrix:D: Math::Matrix $b --> Math::Matrix:D ) {
    fail "Number of columns of the second matrix is different from number of rows of the first operand"
        unless $!column-count == $b!row-count;
    my @product;
    for ^$!row-count X ^$b!column-count -> ($r, $c) {
        @product[$r][$c] += @!rows[$r][$_] * $b!rows[$_][$c] for ^$b!row-count;
    }
    Math::Matrix.new( @product );
}

method tensor-product(Math::Matrix:D: Math::Matrix $b  --> Math::Matrix:D) {
    my @product;
    for @!rows -> $arow {
        for $b!rows -> $brow {
            @product.push([ ($arow.list.map: { $brow.flat >>*>> $_ }).flat ]);
        }
    }
    Math::Matrix.new( @product );
}

################################################################################
# end of matrix math operations - start list like operations
################################################################################

method elems (Math::Matrix:D: --> Int)           {  $!row-count * $!column-count }

method elem (Math::Matrix:D: Range $r --> Bool)  {         # is every element value element in the set/range
    self.list.map: {return False unless $_ ~~ $r};
    True;
}

multi method cont (Math::Matrix:D: Numeric $e  --> Bool) { # matrix contains element ?
    self.list.map: {return True if $_ == $e};
    False;
}
multi method cont (Math::Matrix:D: Range $r  --> Bool) {   # is any element value in this set/range
    self.list.map: {return True if $_ ~~ $r};
    False;
}

method map(Math::Matrix:D: &coderef, Range :$rows = ^$!row-count,
                                     Range :$columns = ^$!column-count --> Math::Matrix:D) {
    self!check-index($rows.min, $columns.min);
    self!check-row-index($rows.minmax[1]) unless $rows.max          == Inf;
    self!check-column-index($columns.minmax[1]) unless $columns.max == Inf;
    my @r = $rows.max    == Inf ?? ($rows.min    .. $!row-count-1).list    !! $rows.list;
    my @c = $columns.max == Inf ?? ($columns.min .. $!column-count-1).list !! $columns.list;
    my @m;
    for @r X @c                        -> ($r, $c) { @m[$r][$c] = &coderef(@!rows[$r][$c])}
    for ^$!row-count X ^$!column-count -> ($r, $c) { @m[$r][$c] //= @!rows[$r][$c] }
    Math::Matrix.new( @m );
}

method map-with-index(Math::Matrix:D: &coderef, Range :$rows = ^$!row-count,
                                                Range :$columns = ^$!column-count --> Math::Matrix:D) {
    fail "block has to receive between one and three arguments" unless &coderef.arity ~~ 1..3;
    self!check-index($rows.min, $columns.min);
    self!check-row-index($rows.minmax[1]) unless $rows.max          == Inf;
    self!check-column-index($columns.minmax[1]) unless $columns.max == Inf;
    my @r = $rows.max    == Inf ?? ($rows.min    .. $!row-count-1).list    !! $rows.list;
    my @c = $columns.max == Inf ?? ($columns.min .. $!column-count-1).list !! $columns.list;
    my @m;
    if    &coderef.arity == 1 {for @r X @c -> ($r, $c) { @m[$r][$c] = &coderef($r) }}
    elsif &coderef.arity == 2 {for @r X @c -> ($r, $c) { @m[$r][$c] = &coderef($r, $c) }}
    elsif &coderef.arity == 3 {for @r X @c -> ($r, $c) { @m[$r][$c] = &coderef($r, $c, @!rows[$r][$c]) }}
    for ^$!row-count X ^$!column-count     -> ($r, $c) { @m[$r][$c] //= @!rows[$r][$c] }
    Math::Matrix.new( @m );
}


method reduce(        Math::Matrix:D: &coderef) {(@!rows.map: {$_.flat}).flat.reduce( &coderef )}
method reduce-rows   (Math::Matrix:D: &coderef) { @!rows.map: { $_.flat.reduce( &coderef) }}
method reduce-columns(Math::Matrix:D: &coderef) {(^$!column-count).map: { self.column($_).reduce( &coderef )}}

################################################################################
# end of list like operations - start structural matrix operations
################################################################################

multi method move-row (Math::Matrix:D: Pair $p --> Math::Matrix:D) {
    self.move-row($p.key, $p.value) 
}
multi method move-row (Math::Matrix:D: Int $from, Int $to --> Math::Matrix:D) {
    self!check-row-indices([$from, $to]);
    return self if $from == $to;
    my @rows = (^$!row-count).list;
    @rows.splice($to,0,@rows.splice($from,1));
    self.submatrix( rows => @rows, columns => (^$!column-count).list);
}

multi method move-column (Math::Matrix:D: Pair $p --> Math::Matrix:D) {
    self.move-column($p.key, $p.value) 
}
multi method move-column (Math::Matrix:D: Int $from, Int $to --> Math::Matrix:D) {
    self!check-column-indices([$from, $to]);
    return self if $from == $to;
    my @cols = (^$!column-count).list;
    @cols.splice($to,0,@cols.splice($from,1));
    self.submatrix( rows => (^$!row-count).list, columns => @cols);
}

method swap-rows (Math::Matrix:D: Int $rowa, Int $rowb --> Math::Matrix:D) {
    self!check-row-indices([$rowa, $rowb]);
    return self if $rowa == $rowb;
    my @rows = (^$!row-count).list;
    (@rows.[$rowa], @rows.[$rowb]) = (@rows.[$rowb], @rows.[$rowa]);
    self.submatrix( rows => @rows, columns => (^$!column-count).list);
}

method swap-columns (Math::Matrix:D: Int $cola, Int $colb --> Math::Matrix:D) {
    self!check-column-indices([$cola, $colb]);
    return self if $cola == $colb;
    my @cols = (^$!column-count).list;
    (@cols.[$cola], @cols.[$colb]) = (@cols.[$colb], @cols.[$cola]);
    self.submatrix( rows => (^$!row-count).list, columns => @cols);
}

multi method splice-rows(Math::Matrix:D: Int $row, Int $elems, Math::Matrix $replacement --> Math::Matrix:D){
    self.splice-rows($row, $elems, $replacement.Array );
}
multi method splice-rows(Math::Matrix:D: Int $row, Int $elems = ($!row-count - $row), Array $replacement = [] --> Math::Matrix:D){
    my $pos = $row >= 0 ?? $row !! $!row-count + $row + 1;
    fail "Row index (first parameter) is outside of matrix size!" unless 0 <= $pos <= $!row-count;
    fail "Number of elements to delete (second parameter) has to be zero or more!)" if $elems < 0;
    if $replacement.elems > 0 {
        fail "Number of columns in and original matrix and replacement has to be same" unless $replacement[0].elems == $!column-count;
        self!check-matrix-data( @$replacement );
    }
    my @m = self!clone-cells;
    @m.splice($pos, $elems, $replacement.list);
    Math::Matrix.new(@m);
}


multi method splice-columns(Math::Matrix:D: Int $col, Int $elems, Math::Matrix $replacement --> Math::Matrix:D){
    self.splice-columns($col, $elems, $replacement.Array );
}
multi method splice-columns(Math::Matrix:D: Int $col, Int $elems = ($!column-count - $col), Array $replacement = ([[] xx $!row-count]) --> Math::Matrix:D){
    my $pos = $col >= 0 ?? $col !! $!column-count + $col + 1;
    fail "Column index (first parameter) is outside of matrix size!" unless 0 <= $pos <= $!column-count;
    fail "Number of elements to delete (second parameter) has to be zero or more!)" if $elems < 0;
    fail "Number of rows in original matrix and replacement has to be same" unless $replacement.elems == $!row-count;
    self!check-matrix-data( @$replacement );
    my @m = self!clone-cells;
    @m.keys.map:{ @m[$_].splice($pos, $elems, $replacement[$_]) };
    Math::Matrix.new(@m);
}

################################################################################
# end of structural matrix operations - start operators
################################################################################

multi sub prefix:<@>( Math::Matrix:D $m --> Array)          is export { $m.Array }
multi sub prefix:<%>( Math::Matrix:D $m --> Hash)           is export { $m.Hash }
multi sub prefix:<->( Math::Matrix:D $m --> Math::Matrix:D) is export { $m.negated }

multi sub circumfix:<｜ ｜>( Math::Matrix:D $m --> Numeric) is equiv(&prefix:<!>) is export { $m.determinant }
multi sub circumfix:<‖ ‖>( Math::Matrix:D $m --> Numeric)  is equiv(&prefix:<!>) is export { $m.norm }


multi sub infix:<+>( Math::Matrix:D $a, Numeric $n        --> Math::Matrix:D) is export { $a.add($n) }
multi sub infix:<+>( Numeric $n,        Math::Matrix:D $a --> Math::Matrix:D) is export { $a.add($n) }
multi sub infix:<+>( Math::Matrix:D $a, Math::Matrix:D $b --> Math::Matrix:D) is export { $a.add($b) }

multi sub infix:<->( Numeric $n,        Math::Matrix:D $a --> Math::Matrix:D) is export { $a.negated.add($n) }
multi sub infix:<->( Math::Matrix:D $a, Numeric $n        --> Math::Matrix:D) is export { $a.add(-$n)  }
multi sub infix:<->( Math::Matrix:D $a, Math::Matrix:D $b --> Math::Matrix:D) is export { $a.subtract($b) }

multi sub infix:<*>( Math::Matrix:D $a, Numeric $n        --> Math::Matrix:D) is export { $a.multiply($n) }
multi sub infix:<*>( Numeric $n,        Math::Matrix:D $a --> Math::Matrix:D) is export { $a.multiply($n) }
multi sub infix:<*>( Math::Matrix:D $a, Math::Matrix:D $b --> Math::Matrix:D) is export { $a.multiply($b) }
multi sub infix:<**>( Math::Matrix:D $a where { $a.is-square }, Int $e --> Math::Matrix:D) is export {
    return Math::Matrix.new-identity( $a!row-count ) if $e == 0;
    my $p = $a.clone;
    $p = $p.dot-product( $a ) for 2 .. abs $e;
    $p = $p.inverted          if  $e < 0;
    $p;
}

multi sub infix:<⋅>(  Math::Matrix:D $a, Math::Matrix:D $b --> Math::Matrix:D) is tighter(&infix:<*>) is export { $a.dot-product( $b ) }
multi sub infix:<dot>(Math::Matrix:D $a, Math::Matrix:D $b --> Math::Matrix:D) is equiv(&infix:<⋅>)   is export { $a.dot-product( $b ) }
multi sub infix:<÷>(  Math::Matrix:D $a, Math::Matrix:D $b --> Math::Matrix:D) is equiv(&infix:<⋅>)   is export { $a.dot-product( $b.inverted ) }

multi sub infix:<⊗>( Math::Matrix:D $a, Math::Matrix:D $b --> Math::Matrix:D) is equiv(&infix:<x>) is export { $a.tensor-product( $b ) }
multi sub infix:<X*>( Math::Matrix:D $a, Math::Matrix:D $b --> Math::Matrix:D) is equiv(&infix:<x>) is export { $a.tensor-product( $b ) }

multi sub prefix:<MM>(Str   $m --> Math::Matrix:D) is tighter(&postcircumfix:<[ ]>) is export(:MM) { Math::Matrix.new($m) }
multi sub prefix:<MM>(List  $m --> Math::Matrix:D) is tighter(&postcircumfix:<[ ]>) is export(:MM) { Math::Matrix.new(@$m) }
