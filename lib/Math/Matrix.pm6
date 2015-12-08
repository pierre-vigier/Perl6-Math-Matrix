unit class Math::Matrix;

has @.rows;
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

multi method Str(Math::Matrix:D: )
{
    @.rows;
}

multi method perl(Math::Matrix:D: )
{
    self.WHAT.perl ~ ".new(" ~ @!rows.perl ~ ")";
    #return "Math::Matrix.new(" ~ @!rows ~ ")";
}

method T(Math::Matrix:D: ) {
    my @transposed;
    for ^$!row-count X ^$!column-count -> ($x, $y) { @transposed[$y][$x] = @!rows[$x][$y] }
    return Math::Matrix.new( @transposed );
}

multi method multiply(Math::Matrix:D: Math::Matrix $b ) {
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

method substract(Math::Matrix:D: Math::Matrix $b where { $!row-count == $b.row-count and $!column-count == $b.column-count } ) {
    my @substract;
    for ^$!row-count X ^$b.column-count -> ($r, $c) {
        @substract[$r][$c] = @!rows[$r][$c] - $b.rows[$r][$c];
    }
    return Math::Matrix.new( @substract );
}

multi sub infix:<⋅>( Math::Matrix $a, Math::Matrix $b where { $a.row-count == $b.column-count} ) is export {
    $a.multiply( $b );
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

multi sub infix:<+>(Math::Matrix $a, Math::Matrix $b) is export {
    $a.add($b);
}

multi sub infix:<->(Math::Matrix $a, Math::Matrix $b) is export {
    $a.substract($b);
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

=head1 METHODS

=head2 method new
    method new( [[1,2],[3,4]])

   A constructor, takes parameters like:
=item rows : an array of row, each row being an array of cells

   Number of cell per row must be identical

=head2 method T

    return a new Matrix, which is the transposition of the current one

=head2 method multiply

    my $product = $matrix1.multiply( $matrix2 )
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

=head2 method substract

    my $new = $matrix.substract( $matrix2 );
    Return substraction of 2 matrices of the same size, can use operator -
    $new = $matrix - $matrix2;

=end pod
