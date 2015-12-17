unit class Math::Matrix;

has @.rows is required;
has Int $.row-count;
has Int $.column-count;

multi method new( @r ) {
    my $col-count;
    for @r -> $row {
        FIRST { $col-count = $row.elems; }
        die "Expect an Array of Array" unless $row ~~ Array;
        die "All Row must contains the same number of elements" unless $row.elems == $col-count;
    }
    self.bless( rows => @r , row-count => @r.elems, column-count => @r[0].elems );
}

my class Row {
    has $.cells;

    multi method new( $c is rw ) {
        self.bless( cells => $c );
    }

    multi method elems(Row:D:) {
        $!cells.elems;
    }

    multi method AT-POS(Row:D: Int $index) {
        $!cells.elems;
        fail X::OutOfRange.new(
            :what<Column index> , :got($index), :range("0..{$!cells.elems - 1}")
        ) unless 0 <= $index < $!cells.elems;
        return-rw $!cells[$index];
    }

    multi method EXISTS-POS( Row:D: $index ) {
        return 0 <= $index < $!cells.elems;
    }
};

multi method elems(Math::Matrix:D: ) {
    @!rows.elems;
}

multi method AT-POS( Math::Matrix:D: Int $index ) {
    fail X::OutOfRange.new(
        :what<Row index> , :got($index), :range("0..{$.row-count -1 }")
    ) unless 0 <= $index < $.row-count;
    return Row.new( @!rows[$index] );
}

multi method EXISTS-POS( Math::Matrix:D: $index ) {
    return 0 <= $index < $.row-count;
}

multi method Str(Math::Matrix:D: )
{
    @.rows;
}

multi method perl(Math::Matrix:D: )
{
    self.WHAT.perl ~ ".new(" ~ @!rows.perl ~ ")";
}

method equal(Math::Matrix:D: Math::Matrix $b) {
    self.rows ~~ $b.rows;
}

method T(Math::Matrix:D: ) {
    my @transposed;
    for ^$!row-count X ^$!column-count -> ($x, $y) { @transposed[$y][$x] = @!rows[$x][$y] }
    return Math::Matrix.new( @transposed );
}

multi method dotProduct(Math::Matrix:D: Math::Matrix $b ) {
    my @product;
    die "Number of columns of the second matrix is different from number of rows of the first operand" unless self.column-count == $b.row-count;
    for ^$!row-count X ^$b.column-count -> ($r, $c) {
        @product[$r][$c] += @!rows[$r][$_] * $b.rows[$_][$c] for ^$b.row-count;
    }
    return Math::Matrix.new( @product );;
}

multi method multiply(Math::Matrix:D: Real $r ) {
    self.apply( * * $r );
}

method apply(Math::Matrix:D: &coderef) {
    return Math::Matrix.new( @.rows.map: {
            [ $_.map( &coderef ) ]
    });
}

method negative() {
    self.apply( - * );
}

method add(Math::Matrix:D: Math::Matrix $b where { $!row-count == $b.row-count and $!column-count == $b.column-count } ) {
    my @sum;
    for ^$!row-count X ^$b.column-count -> ($r, $c) {
        @sum[$r][$c] = @!rows[$r][$c] + $b.rows[$r][$c];
    }
    return Math::Matrix.new( @sum );
}

method subtract(Math::Matrix:D: Math::Matrix $b where { $!row-count == $b.row-count and $!column-count == $b.column-count } ) {
    my @subtract;
    for ^$!row-count X ^$b.column-count -> ($r, $c) {
        @subtract[$r][$c] = @!rows[$r][$c] - $b.rows[$r][$c];
    }
    return Math::Matrix.new( @subtract );
}

multi method multiply(Math::Matrix:D: Math::Matrix $b where { $!row-count == $b.row-count and $!column-count == $b.column-count } ) {
    my @multiply;
    for ^$!row-count X ^$b.column-count -> ($r, $c) {
        @multiply[$r][$c] = @!rows[$r][$c] * $b.rows[$r][$c];
    }
    return Math::Matrix.new( @multiply );
}

multi method determinant(Math::Matrix:D: ) {
    fail "Not square matrix" unless $!row-count == $!column-count;
    fail "Matrix has to have at least 2 lines/columns" unless $!row-count >= 2;
    if $!row-count == 2 {
        return @!rows[0][0] * @!rows[1][1] - @!rows[0][1] * @!rows[1][0];
    } else {
        my $det = 0;
        for ^$!column-count -> $x {
            my @intermediate;
            for 1..^$!row-count -> $r {
                my @r;
                for (0..^$x,$x^..^$!column-count).flat -> $c {
                        @r.push( @!rows[$r][$c] );
                }
                @intermediate.push( [@r] );
            }
            if $x %% 2 {
                $det += @!rows[0][$x] * Math::Matrix.new( @intermediate ).determinant();
            } else {
                $det -= @!rows[0][$x] * Math::Matrix.new( @intermediate ).determinant();
            }
        }
        return $det;
    }
}

multi sub infix:<⋅>( Math::Matrix $a, Math::Matrix $b where { $a.column-count == $b.row-count} ) is export {
    $a.dotProduct( $b );
}

multi sub infix:<dot>(Math::Matrix $a, Math::Matrix $b) is export {
    $a ⋅ $b;
}

multi sub infix:<*>(Math::Matrix $a, Real $r) is export {
    $a.multiply( $r );
}

multi sub infix:<*>(Real $r, Math::Matrix $a) is export {
    $a.multiply( $r );
}

multi sub infix:<*>(Math::Matrix $a, Math::Matrix $b  where { $a.row-count == $b.row-count and $a.column-count == $b.column-count}) is export {
    $a.multiply( $b );
}

multi sub infix:<+>(Math::Matrix $a, Math::Matrix $b) is export {
    $a.add($b);
}

multi sub infix:<->(Math::Matrix $a, Math::Matrix $b) is export {
    $a.subtract($b);
}

=begin pod
=head1 NAME
Math::Matrix - Simple Matrix mathematics
=head1 SYNOPSIS

Matrix stuff, transposition, dot Product, and so on

=head1 DESCRIPTION

Perl6 already provide a lot of tools to work with array, shaped array, and so on,
however, even hyper operators does not seem to be enough to do matrix calculation
Purpose of that library is to propose some tools for Matrix calculation

I should probably use shaped array for the implementation, but i am encountering
some issues for now. Problem being it might break the syntax for creation of a Matrix, 
use with consideration...

=head1 METHODS

=head2 method new
    method new( [[1,2],[3,4]])

   A constructor, takes parameters like:
=item rows : an array of row, each row being an array of cells

   Number of cell per row must be identical

=head2 method T

    return a new Matrix, which is the transposition of the current one

=head2 method dotProduct

    my $product = $matrix1.dotProduct( $matrix2 )
    return a new Matrix, result of the dotProduct of the current matrix with matrix2
    Call be called throug operator ⋅ or dot , like following:
    my $c = $a ⋅ $b ;
    my $c = $a dot $b ;

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

=end pod
