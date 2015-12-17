# Perl6-Math-Matrix

[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix)

NAME Math::Matrix - Simple Matrix mathematics
=============================================

SYNOPSIS
========

Matrix stuff, transposition, dot Product, and so on

DESCRIPTION
===========

Perl6 already provide a lot of tools to work with array, shaped array, and so on, however, even hyper operators does not seem to be enough to do matrix calculation Purpose of that library is to propose some tools for Matrix calculation

I should probably use shaped array for the implementation, but i am encountering some issues for now. Problem being it might break the syntax for creation of a Matrix,  use with consideration...

METHODS
=======

method new method new( [[1,2],[3,4]])
-------------------------------------

    A constructor, takes parameters like:

  * rows : an array of row, each row being an array of cells

    Number of cell per row must be identical

method T
--------

    return a new Matrix, which is the transposition of the current one

method dotProduct
-----------------

    my $product = $matrix1.dotProduct( $matrix2 )
    return a new Matrix, result of the dotProduct of the current matrix with matrix2
    Call be called throug operator ⋅ or dot , like following:
    my $c = $a ⋅ $b ;
    my $c = $a dot $b ;

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
----------------

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

