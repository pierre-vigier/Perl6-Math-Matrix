# Perl6-Math-Matrix

[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix)

NAME Math::Matrix - Simple Matrix mathematics
=============================================

SYNOPSIS
========

Matrix stuff, transposition, dot Product, and so on

DESCRIPTION
===========

Perl6 already provide a lot of tools to work with array, shaped array, and so on, however, even hyper operators does not seem to be enough to do matrix calculation Purpose of that library is to propose some tools for Matrix calculation.

I should probably use shaped array for the implementation, but i am encountering some issues for now. Problem being it might break the syntax for creation of a Matrix, use with consideration...

METHODS
=======

method new method new( [[1,2],[3,4]])
-------------------------------------

    A constructor, takes parameters like:

  * rows : an array of row, each row being an array of cells

    Number of cells per row must be identical

method new-identity
-------------------

    my $matrix = Math::Matrix.new-identity( 3 );
    This method is a constructor that returns an identity matrix of the size given in parameter
    All the cells are set to 0 except the top/left to bottom/right diagonale, set to 1

method new-zero
---------------

    my $matrix = Math::Matrix.new-zero( 3, 4 );
    This method is a constructor that returns an zero matrix of the size given in parameter.
    If only one parameter is given, the matrix is quadratic. All the cells are set to 0.

method new-diagonal
-------------------

    my $matrix = Math::Matrix.new-diagonal( 2, 4, 5 );
    This method is a constructor that returns an diagonal matrix of the size given
    by count of the parameter.
    All the cells are set to 0 except the top/left to bottom/right diagonal,
    set to given values.

method new-vector-product
-------------------------

    my $matrixp = Math::Matrix.new-vector-product([1,2,3],[2,3,4]);
    my $matrix = Math::Matrix.new([2,3,4],[4,6,8],[6,9,12]);       # same matrix

    This method is a constructor that returns a matrix which is a result of 
    the matrix product (method dotProduct, or operator dot) of a column vector
    (first argument) and a row vector (second argument).

method equal
------------

    if $matrixa.equal( $matrixb ) {
    if $matrixa ~~ $matrixb {

    Checks two matrices for Equality

method size
-----------

    List of two values: number of rows and number of columns.

    say $matrix.size();
    my $dim = min $matrix.size();

method density
--------------

    say 'this is a fully (occupied) matrix' if $matrix.density() == 1;

    percentage of cells which hold a value different than 0

method is-square
----------------

    if $matrix.is-square {

    Tells if number of rows and colums are the same

method is-zero
--------------

    True if every cell has value of 0.

method is-identity
------------------

    True if every cell on the diagonal (where row index equals column index) is 1
    and any other cell is 0.

method is-diagonal
------------------

    True if only cell on the diagonal differ from 0.

method is-diagonally-dominant
-----------------------------

    True if cells on the diagonal have a bigger or equal absolute value than the
    sum of the other absolute values in the column.

    if $matrix.is-diagonally-dominant {
    $matrix.is-diagonally-dominant(:!strict)   # same thing (default)
    $matrix.is-diagonally-dominant(:strict)    # diagonal elements (DE) are stricly greater (>)
    $matrix.is-diagonally-dominant(:!strict, :along<column>) # default
    $matrix.is-diagonally-dominant(:strict,  :along<row>)    # DE > sum of rest row
    $matrix.is-diagonally-dominant(:!strict, :along<both>)   # DE >= sum of rest row and rest column

method is-upper-triangular
--------------------------

    True if every cell below the diagonal (where row index is greater than column index) is 0.

method is-lower-triangular
--------------------------

    True if every cell above the diagonal (where row index is smaller than column index) is 0.

method is-symmetric
-------------------

    if $matrix.is-symmetric {

    Is True if every cell with coordinates x y has same value as the cell on y x.

method is-positive-definite
---------------------------

    True if all main minors are positive

method is-orthogonal
--------------------

    if $matrix.is-orthogonal {

    Is True if the matrix multiplied (dotProduct) with its transposed version (T)
    is an identity matrix.

method is-invertible
--------------------

    Is True if number of rows and colums are the same and determinant is not zero.

method transposed, alias T
--------------------------

    return a new Matrix, which is the transposition of the current one

method inverted
---------------

    return a new Matrix, which is the inverted of the current one

method dotProduct
-----------------

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

method apply
------------

    my $new = $matrix.apply( * + 2 );
    return a new matrix which is the current one with the function given in parameter applied to every cells

method negative
---------------

    my $new = $matrix.negative();
    return the negative of a matrix

method add
----------

    my $new = $matrix.add( $matrix2 );
    Return addition of 2 matrices of the same size, can use operator +
    $new = $matrix + $matrix2;

method subtract
---------------

    my $new = $matrix.subtract( $matrix2 );
    Return substraction of 2 matrices of the same size, can use operator -
    $new = $matrix - $matrix2;

method multiply
---------------

    my $new = $matrix.multiply( $matrix2 );
    Return multiply of elements of 2 matrices of the same size, can use operator *
    $new = $matrix * $matrix2;

method determinant
------------------

    my $det = $matrix.determinant( );
    Calculate the determinant of a square matrix

method trace
------------

    my $tr = $matrix.trace( );
    Calculate the trace of a square matrix

method rank
-----------

    my $r = $matrix.rank( );
    rank is the number of independent row or column vectors
    or also called independent dimensions
    (thats why this command is sometimes calles dim)

method kernel
-------------

    my $tr = $matrix.kernel( );
    kernel of matrix, number of dependent rows or columns

method norm
-----------

    my $norm = $matrix.norm( );          # euclidian norm (L2, p = 2)
    my $norm = ||$matrix||;              # operator shortcut to do the same
    my $norm = $matrix.norm(1);          # p-norm, L1 = sum of all cells
    my $norm = $matrix.norm(p:<4>,q:<3>);# p,q - norm, p = 4, q = 3
    my $norm = $matrix.norm(p:<2>,q:<2>);# Frobenius norm
    my $norm = $matrix.norm('max');      # max norm - biggest absolute value of a cell
    $matrix.norm('rowsum');              # row sum norm - biggest abs. value-sum of a row
    $matrix.norm('columnsum');           # column sum norm - same column wise

method decompositionLU
----------------------

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

method decompositionLUCrout
---------------------------

    my ($L, $U) = $matrix.decompositionLUCrout( );
    $L dot $U eq $matrix;                # True

    $L is a left triangular matrix and $R is a right one
    This decomposition works only on invertible matrices (square and full ranked).

method decompositionCholesky
----------------------------

    my $D = $matrix.decompositionCholesky( );
    $D dot $D.T eq $matrix;              # True 

    $D is a left triangular matrix
    This decomposition works only on symmetric and definite positive matrices.
