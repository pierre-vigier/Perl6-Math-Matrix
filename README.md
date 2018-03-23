# Perl6-Math-Matrix

[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix)

NAME
====

Math::Matrix - create, compare, compute and measure 2D matrices

VERSION
=======

0.1.8

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

METHODS
=======

  * constructors: new, new-zero, new-identity, new-diagonal, new-vector-product

  * accessors: cell, row, column, diagonal, submatrix

  * conversion: Bool, Numeric, Str, perl, list-rows, list-columns, gist, full

  * boolean properties: equal, is-zero, is-identity, is-square, is-diagonal, is-diagonally-dominant, is-upper-triangular, is-lower-triangular, is-invertible, is-symmetric, is-unitary, is-self-adjoint, is-orthogonal, is-positive-definite, is-positive-semidefinite

  * numeric properties: size, elems, density, trace, determinant, rank, kernel, norm, condition

  * derived matrices: transposed, negated, conjugated, inverted, reduced-row-echelon-form

  * decompositions: decompositionLUCrout, decompositionLU, decompositionCholesky

  * matrix math ops: add, subtract, add-row, add-column, multiply, multiply-row, multiply-column, dotProduct, tensorProduct

  * structural ops: map, map-row, map-column, reduce, reduce-rows, reduce-columns

  * operators: +, -, *, **, ⋅, dot, ⊗, x, | |, || ||

Constructors
------------

### new( [[...],...,[...]] )

The default constructor, takes arrays of arrays of numbers. Each second level array represents a row in the matrix. That is why their length has to be the same.

    Math::Matrix.new( [[1,2],[3,4]] ) creates:

    1 2
    3 4

### new-zero

This method is a constructor that returns an zero matrix of the size given in parameter. If only one parameter is given, the matrix is quadratic. All the cells are set to 0.

    say Math::Matrix.new-zero( 3, 4 ) :

    0 0 0 0
    0 0 0 0
    0 0 0 0

### new-identity

This method is a constructor that returns an identity matrix of the size given in parameter All the cells are set to 0 except the top/left to bottom/right diagonale, set to 1

    say Math::Matrix.new-identity( 3 ):
      
    1 0 0
    0 1 0
    0 0 1

### new-diagonal

This method is a constructor that returns an diagonal matrix of the size given by count of the parameter. All the cells are set to 0 except the top/left to bottom/right diagonal, set to given values.

    say Math::Matrix.new-diagonal( 2, 4, 5 ):

    2 0 0
    0 4 0
    0 0 5

### new-vector-product

This method is a constructor that returns a matrix which is a result of the matrix product (method dotProduct, or operator dot) of a column vector (first argument) and a row vector (second argument).

    my $matrixp = Math::Matrix.new-vector-product([1,2,3],[2,3,4]);
    my $matrix = Math::Matrix.new([2,3,4],[4,6,8],[6,9,12]);       # same matrix

Accessors
---------

### cell

    Gets value of element in third row and fourth column. (counting always from 0)

    my $value = $matrix.cell(2,3);

### row

    Gets values of specified row (first required parameter) as a list.
    That would be (1, 2) if matrix is [[1,2][3,4]].

    my @values = $matrix.row(0);

### column

    Gets values of specified column (first required parameter) as a list.
    That would be (1, 4) if matrix is [[1,2][3,4]].

    my @values = $matrix.column(0);

### diagonal

    Gets values of diagonal elements. That would be (1, 4) if matrix is [[1,2][3,4]].

    my @values = $matrix.diagonal();

### submatrix

    Subset of cells of a given matrix by deleting rows and/or columns. 

    The first and simplest usage is by choosing a cell (by coordinates).
    Row and column of that cell will be removed.

    my $m = Math::Matrix.new([[1,2,3,4][2,3,4,5],[3,4,5,6]]);     # 1 2 3 4
                                                                    2 3 4 5
                                                                    3 4 5 6
    say $m.submatrix(1,2);     # 1 2 4
                                 3 4 6                            

    If you provide two pairs of coordinates (row column), these will be counted as
    left upper and right lower corner of and area inside the original matrix,
    which will the resulting submatrix.

    say $m.submatrix(1,1,1,3); # 2 3 4        

    When provided with two lists of values (one for the rows - one for columns)
    a new matrix will be created with the old rows and columns in that new order.

    $m.submatrix((3,2),(1,2)); # 4 5
                                 3 4

Type Conversion And Output Flavour
----------------------------------

### Bool

    Conversion into Bool context. Returns False if matrix is zero
    (all cells equal zero as in is-zero), otherwise True.

    $matrix.Bool
    ? $matrix           # alias
    if $matrix          # Bool context too

### Numeric

    Conversion into Numeric context. Returns number (amount) of cells (as .elems).
    Please note, only prefix a prefix + (as in: + $matrix) will call this Method.
    A infix (as in $matrix + $number) calls .add($number).

    $matrix.Numeric   or      + $matrix

### Str

    Conversion into String context. Returns content of all cells in the
    data structure form like "[[..,..,...],[...],...]"

    put $matrix     or      print $matrix

### reduce-columns

Similar to reduce-rows, this method reduces each column to one value in the resulting list:

    say Math::Matrix.new( [[1,2],[3,4]] ).reduce-columns(&[*]);  # prints (3, 8)

Operators
=========

The Module overloads or uses a range of well and less known ops. +, -, * and ~~ are commutative.

    my $a   = +$matrix               # Num context, amount (count) of cells
    my $b   = ?$matrix               # Bool context, True if any cell has a none zero value
    my $str = ~$matrix               # String context, matrix content as data structure

    $matrixa ~~ $matrixb             # check if both have same size and they are cell wise equal

    my $sum =  $matrixa + $matrixb;  # cell wise sum of two same sized matrices
    my $sum =  $matrix  + $number;   # add number to every cell

    my $dif =  $matrixa - $matrixb;  # cell wise difference of two same sized matrices
    my $dif =  $matrix  - $number;   # subtract number from every cell
    my $neg = -$matrix               # negate value of every cell

    my $p   =  $matrixa * $matrixb;  # cell wise product of two same sized matrices
    my $sp  =  $matrix  * $number;   # multiply number to every cell

    my $tp  =  $a x $b;              # tensor product 
    my $tp  =  $a ⊗ $b;              # tensor product, unicode alias

    my $dp  =  $a dot $b;            # dot product of two fitting matrices (cols a = rows b)
    my $dp  =  $a ⋅ $b;              # dot product, unicode alias

    my $c   =  $a **  3;             # $a to the power of 3, same as $a dot $a dot $a
    my $c   =  $a ** -3;             # alias to ($a dot $a dot $a).inverted
    my $c   =  $a **  0;             # creats an right sized identity matrix

     | $matrix |                     # determinant
    || $matrix ||                    # Euclidean (L2) norm

Author
======

Pierre VIGIER

Contributors
============

Herbert Breunung

License
=======

Artistic License 2.0

