use v6.c;
use Math::Matrix::Type;

unit module Math::Matrix::ArrayOfArray;

################################################################################
# constructors
################################################################################

our sub new-uniform( PosInt $rows, PosInt $cols, Numeric $content ) { [ [ $content xx $cols ] xx $rows ] }
our sub new-zero( PosInt $rows, PosInt $cols = $rows )              { new-uniform($rows, $cols, 0) }

our sub new-identity( PosInt $size ) {
    my @identity = new-zero($size);
    @identity[$_][$_] = 1 for ^$size;
    @identity;
}

our sub new-diagonal( NumList $diag ) {
    my @diagonal = new-zero( $diag.elems );
    for ^$diag.elems -> $i { @diagonal[$i][$i] = $diag[$i] }
    @diagonal;
}


################################################################################

our sub clone (@m) {[ @m.map: {[ $^row.flat.map({$^element.clone}) ]} ]}

################################################################################

our sub check-data (@m) {
    fail "Expect an Array or Array or List of Lists" unless (@m ~~ Array and all @m ~~ Array)
                                                         or (@m ~~ List and all @m ~~ List);
    fail "Expect the Array or List to have elements" if @m == 0 or @m[0] == 0;
    fail "All rows must contains the same number of elements" unless @m == 1 or @m[0] == all @m[*];
    fail "All rows must contain only numeric values" unless all( @m[*;*] ) ~~ Numeric;
}

our sub check-size-equal(@a, @b){
    fail "Expect same amount of rows in both operands, but got {@a.elems} and {@b.elems}" unless @a == @b;
    for ^@a.elems -> $row {
        fail "Expect same amount of elements in row $row in both operands, but got {@a[$row].elems} and {@b[$row].elems}"
            unless @a[$row] == @b[$row];
    }
}

our sub check-size-conformable(@a, @b){ # for multiplication
    fail "All rows of first operand must contains the same number of elements" unless @a == 1 or @a[0] == all @a[*];
    fail "All rows of second operand must contains the same number of elements" unless @b == 1 or @b[0] == all @b[*];
    fail "Number of columns in left operand has to equal number of rows on right" unless @a[0] == @b;
}

our sub transpose(@m){
    my @t = [Z] @m;
    @t.map: *.Array;
}

our sub add(@a, @b){
    my @sum = clone(@a);
    for ^@a.elems -> $row { @sum[$row] = @sum[$row] <<+>> @b[$row] }
    @sum;
}

our sub multiply(@a, @b){
    my @bt = transpose(@b);
    my @product;
    for ^@a.elems X ^@b.elems -> ($row, $col) {
        @product[$row][$col] = [+] (@a[$row] <<*>> @b[$col]);
    }
    @product;
}

our sub map (@m, &coderef){
    my @res = clone(@m);
    for ^@m.elems -> $row { @res[$row] = @res[$row].map(&coderef) }
    @res;
}
