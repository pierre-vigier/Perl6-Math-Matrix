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

