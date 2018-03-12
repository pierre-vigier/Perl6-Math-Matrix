# Perl6-Math-Matrix

[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix)

NAME
====

Math::Matrix - create, compare, compute and measure 2D matrices

VERSION
=======

0.13

SYNOPSIS
========

Matrices are tables with rows (counting from 0) and columns of numbers: 

    transpose, invert, negate, add, subtract, multiply, dot product, size, determinant, 
    rank, kernel, trace, norm, decompositions and so on

DESCRIPTION
===========

Perl6 already provide a lot of tools to work with array, shaped array, and so on, however, even hyper operators does not seem to be enough to do matrix calculation Purpose of that library is to propose some tools for Matrix calculation.

I should probably use shaped array for the implementation, but i am encountering some issues for now. Problem being it might break the syntax for creation of a Matrix, use with consideration...

Matrices are readonly - all operations and derivatives are new objects.

Type Conversion
===============

In Str context you will see a tabular representation, in Int the number of cells and in Bool context if the matrix is not zero (all cells are zero as in is-zero).

METHODS
=======

  * constructors: new, new-zero, new-identity, new-diagonal, new-vector-product

  * accessors: cell, row, column, diagonal, submatrix

  * boolean properties: equal, is-square, is-invertible, is-zero, is-identity is-upper-triangular, is-lower-triangular, is-diagonal, is-diagonally-dominant is-symmetric, is-orthogonal, is-positive-definite

  * numeric properties: size, determinant, rank, kernel, trace, density, norm, condition

  * derivative matrices: transposed, negated, inverted, reduced-row-echelon-form

  * decompositions: decompositionLUCrout, decompositionLU, decompositionCholesky

  * matrix operations: add, subtract, multiply, dotProduct

method new( [[...],...,[...]] )
-------------------------------

    The default constructor, takes arrays of arrays of numbers.
    Each second level array represents a row in the matrix.
    That is why their length has to be the same. 
    .new( [[1,2],[3,4]] ) creates:

    1 2
    3 4

method new-zero
---------------

    my $matrix = Math::Matrix.new-zero( 3, 4 );
    This method is a constructor that returns an zero matrix of the size given in parameter.
    If only one parameter is given, the matrix is quadratic. All the cells are set to 0.

method new-identity
-------------------

    my $matrix = Math::Matrix.new-identity( 3 );
    This method is a constructor that returns an identity matrix of the size given in parameter
    All the cells are set to 0 except the top/left to bottom/right diagonale, set to 1

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

method cell
-----------

    my $value = $matrix.cell(2,3);

    Gets value of element in third row and fourth column.

method row
----------

    my @values = $matrix.row();

    Gets values of diagonal elements.
    That would be (1, 4) if matrix is [[1,2][3,4]].

method column
-------------

    my @values = $matrix.row();

    Gets values of diagonal elements.
    That would be (1, 4) if matrix is [[1,2][3,4]].

method diagonal
---------------

    my @values = $matrix.diagonal();

    Gets values of diagonal elements.
    That would be (1, 4) if matrix is [[1,2][3,4]].

method submatrix
----------------

    Return a subset of a given matrix. 
    Given $matrix = Math::Matrix.new([[1,2,3][4,5,6],[7,8,9]]);
    A submatrix with one row and two columns:

    $matrix.submatrix(1,2);              # is [[1,2]]

    A submatrix from cell (0,1) on to left and down till cell (1,2):

    $matrix.submatrix(0,1,1,2);          # is [[2,3],[5,6]]

    When I just want cells in row 0 and 2 and colum 1 and 2 I use:

    $matrix.submatrix((0,2),(1..2));     # is [[2,3],[8,9]]

method equal
------------

    if $matrixa.equal( $matrixb ) {
    if $matrixa ~~ $matrixb {

    Checks two matrices for Equality

method is-square
----------------

    if $matrix.is-square {

    True if number of rows and colums are the same

method is-invertible
--------------------

    Is True if number of rows and colums are the same and determinant is not zero.

method is-zero
--------------

    True if every cell has value of 0.

method is-identity
------------------

    True if every cell on the diagonal (where row index equals column index) is 1
    and any other cell is 0.

method is-upper-triangular
--------------------------

    True if every cell below the diagonal (where row index is greater than column index) is 0.

method is-lower-triangular
--------------------------

    True if every cell above the diagonal (where row index is smaller than column index) is 0.

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

method is-symmetric
-------------------

    if $matrix.is-symmetric {

    Is True if every cell with coordinates x y has same value as the cell on y x.

method is-orthogonal
--------------------

    if $matrix.is-orthogonal {

    Is True if the matrix multiplied (dotProduct) with its transposed version (T)
    is an identity matrix.

method is-positive-definite
---------------------------

    True if all main minors are positive

method size
-----------

    List of two values: number of rows and number of columns.

    say $matrix.size();
    my $dim = min $matrix.size();

method determinant (short det)
------------------------------

    my $det = $matrix.determinant( );
    my $d = $matrix.det( );     #    Calculate the determinant of a square matrix

method trace
------------

    my $tr = $matrix.trace( ); 

    The trace of a square matrix is the sum of the cells on the main diagonal.
    In other words: sum of cells which row and column value is identical.

method density
--------------

    my $d = $matrix.density( );   

    Density is the percentage of cell which are not zero.

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

method condition
----------------

    my $c = $matrix.condition( );        

    Condition number of a matrix is L2 norm * L2 of inverted matrix.

method transposed, alias T
--------------------------

    return a new Matrix, which is the transposition of the current one

method inverted
---------------

    return a new Matrix, which is the inverted of the current one

method negated
--------------

    my $new = $matrix.negated();    # invert sign of all cells
    my $neg = - $matrix;            # works too

method reduced-row-echelon-form (shortcut rref)
-----------------------------------------------

    my $rref = $matrix.reduced-row-echelon-form();
    my $rref = $matrix.rref();

    Return the reduced row echelon form of a matrix, a.k.a. row canonical form

method decompositionLUCrout
---------------------------

    my ($L, $U) = $matrix.decompositionLUCrout( );
    $L dot $U eq $matrix;                # True

    $L is a left triangular matrix and $R is a right one
    This decomposition works only on invertible matrices (square and full ranked).

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

method decompositionCholesky
----------------------------

    my $D = $matrix.decompositionCholesky( );  # $D is a left triangular matrix
    $D dot $D.T eq $matrix;                    # True 

    This decomposition works only on symmetric and definite positive matrices.

method add
----------

    my $sum = $matrix.add( $matrix2 );  # cell wise addition of 2 same sized matrices
    my $s = $matrix + $matrix2;         # works too

    my $sum = $matrix.add( $number );   # adds number from every cell 
    my $s = $matrix + $number;          # works too

method subtract
---------------

    my $diff = $matrix.subtract( $matrix2 );  # cell wise subraction of 2 same sized matrices
    my $d = $matrix - $matrix2;               # works too

    my $diff = $matrix.subtract( $number );   # subtracts number from every cell 
    my $sd = $matrix - $number;               # works too

method multiply
---------------

    my $product = $matrix.multiply( $matrix2 );  # cell wise multiplication of same size matrices
    my $p = $matrix * $matrix2;                  # works too

    my $product = $matrix.multiply( $number );   # multiply every cell with number
    my $p = $matrix * $number;                   # works too

method dotProduct
-----------------

    my $product = $matrix1.dotProduct( $matrix2 )
    return a new Matrix, result of the dotProduct of the current matrix with matrix2
    Call be called throug operator ⋅ or dot , like following:
    my $c = $a ⋅ $b;
    my $c = $a dot $b;

    A shortcut for multiplication is the power - operator **
    my $c = $a **  3;               # same as $a dot $a dot $a
    my $c = $a ** -3;               # same as ($a dot $a dot $a).inverted
    my $c = $a **  0;               # created an right sized identity matrix

Author
======

Pierre VIGIER

Contributors
============

Herbert Breunung

License
=======

Artistic License 2.0

