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

I should probably use shaped array for the implementation, but i am encountering some issues for now. Problem being it might break the syntax for creation of a Matrix,  use with consideration...

METHODS
=======

method new method new( [[1,2],[3,4]])
-------------------------------------

    A constructor, takes parameters like:

  * rows : an array of row, each row being an array of cells

    Number of cell per row must be identical

method diagonal
---------------

    my $matrix = Math::Matrix.diagonal( 2, 4, 5 );
    This method is a constructor that returns an diagonal matrix of the size given 
    by count of the parameter.
    All the cells are set to 0 except the top/left to bottom/right diagonale, 
    set to given values.

method identity
---------------

    my $matrix = Math::Matrix.identity( 3 );
    This method is a constructor that returns an identity matrix of the size given in parameter
    All the cells are set to 0 except the top/left to bottom/right diagonale, set to 1

method zero
-----------

    my $matrix = Math::Matrix.zero( 3, 4 );
    This method is a constructor that returns an zero matrix of the size given in parameter.
    If only one parameter is given, the matrix is quadratic. All the cells are set to 0.

method equal
------------

    if $matrixa.equal( $matrixb ) {
    if $matrixa ~~ $matrixb {

    Checks two matrices for Equality

method is-square
----------------

    if $matrix.is-square {

    Tells if number of rows and colums are the same

method is-symmetric
-------------------

    if $matrix.is-symmetric {

    Returns True if every cell with coordinates x y has same value as the cell on y x.

method is-orthogonal
--------------------

    if $matrix.is-orthogonal {

    Is True if the matrix multiplied (dotProduct) with its transposed version (T)
    is an identity matrix.

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

method density
--------------

    my $dst = $matrix.density( );      #  number of none-zero values / all cells
    useful to idenify sparse and full matrices

method rank
-----------

    my $r = $matrix.rank( );
    rank is the number of independent row or column vectors
    or als calles independent dimensions 
    (thats why this command is sometimes calles dim)

method kernel
-------------

    my $tr = $matrix.kernel( );
    kernel of matrix, number of dependent rows or columns

method norm
-----------

    my $norm = $matrix.norm( );   # euclidian norm (L2, p = 2)
    my $norm = ||$matrix||;       # operator shortcut to do the same
    my $norm = $matrix.norm(1);   # p-norm, L1 = sum of all cells
    my $norm = $matrix.norm(4,3); # p,q - norm, p = 4, q = 3
