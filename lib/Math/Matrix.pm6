unit class Math::Matrix;

has $.cells is readonly;

method new( @c ) {
    die "Expect an Array of Array" unless all @c ~~ Array;
    die "All Row must contains the same number of elements" unless @c[0] == all @c[*];
    my Numeric @array[@c.elems,@c[0].elems] = @c.map( *.flat );
    self.bless( cells => @array );
}

multi method Str(Math::Matrix:D: )
{
    $!cells;
}

multi method perl(Math::Matrix:D: )
{
    self.WHAT.perl ~ ".new(" ~ $!cells.perl ~ ")";
}

method equal(Math::Matrix:D: Math::Matrix $b) {
    $.cells.shape eqv $b.cells.shape && $.cells.values eqv $b.cells.values;
}

method T(Math::Matrix:D: ) {
    my @transposed;
    for ^$!cells.shape[0] X ^$!cells.shape[1] -> ($x, $y) { @transposed[$y][$x] = $!cells[$x;$y] }
    return Math::Matrix.new( @transposed );
}

multi method dotProduct(Math::Matrix:D: Math::Matrix $b ) {
    my @product;
    die "Number of columns of the first matrix is different from number of rows of the second operand" unless $!cells.shape[1] == $b.cells.shape[0];
    for ^$!cells.shape[0] X ^$b.cells.shape[1] -> ($r, $c) {
        @product[$r][$c] += $!cells[$r;$_] * $b.cells[$_;$c] for ^$b.cells.shape[0];
    }
    return Math::Matrix.new( @product );;
}

method negative() {
    my Numeric @neg[$!cells.shape[0],$!cells.shape[1]] = $!cells.map( - * ).rotor($!cells.shape[0]);
    return self.bless( cells => @neg );
}

method add(Math::Matrix:D: Math::Matrix $b) { #$b where { self.cells.shape eqv $b.cells.shape } ) {
    #say $.cells >>+<< $b.cells;
    say $.cells;
    say $b.cells;
    say $.cells >>+<< $b.cells;
    #my Numeric @sum[$!cells.shape[0],$!cells.shape[1]] = (self.cells >>+<< $b.cells).rotor($!cells.shape[0]);
    #return Math::Matrix.new( @sum );
}

multi sub infix:<⋅>( Math::Matrix $a, Math::Matrix $b where { $a.cells.shape[1] == $b.cells.shape[0]} ) is export {
    $a.dotProduct( $b );
}

multi sub infix:<dot>(Math::Matrix $a, Math::Matrix $b) is export {
    $a ⋅ $b;
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
