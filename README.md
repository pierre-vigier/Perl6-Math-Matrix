# Perl6-Math-Matrix

[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-Math-Matrix)

NAME
====

Math::Matrix - create, compare, compute and measure 2D matrices

VERSION
=======

0.1.7

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

  * boolean properties: equal, is-square, is-invertible, is-zero, is-identity, is-upper-triangular, is-lower-triangular, is-diagonal, is-diagonally-dominant, is-symmetric, is-orthogonal, is-positive-definite

  * numeric properties: size, elems, density, trace, determinant, rank, kernel, norm, condition

  * derivative matrices: transposed, negated, inverted, reduced-row-echelon-form

  * decompositions: decompositionLUCrout, decompositionLU, decompositionCholesky

  * matrix math ops: add, subtract, multiply, dotProduct, map, reduce, reduce-rows, reduce-columns

  * operators: +, -, *, **, ⋅, dot, | |, || ||

Constructors
------------

### new( [[...],...,[...]] )

    The default constructor, takes arrays of arrays of numbers.
    Each second level array represents a row in the matrix.
    That is why their length has to be the same.

    Math::Matrix.new( [[1,2],[3,4]] ) creates:

    1 2
    3 4

### new-zero

    This method is a constructor that returns an zero matrix of the size given in parameter.
    If only one parameter is given, the matrix is quadratic. All the cells are set to 0.

    say Math::Matrix.new-zero( 3, 4 ) :

    0 0 0 0
    0 0 0 0
    0 0 0 0

### new-identity

    This method is a constructor that returns an identity matrix of the size given in parameter
    All the cells are set to 0 except the top/left to bottom/right diagonale, set to 1

    say Math::Matrix.new-identity( 3 ):
      
    1 0 0
    0 1 0
    0 0 1

### new-diagonal

    This method is a constructor that returns an diagonal matrix of the size given
    by count of the parameter.
    All the cells are set to 0 except the top/left to bottom/right diagonal,
    set to given values.

    say Math::Matrix.new-diagonal( 2, 4, 5 ):

    2 0 0
    0 4 0
    0 0 5

### new-vector-product

    This method is a constructor that returns a matrix which is a result of 
    the matrix product (method dotProduct, or operator dot) of a column vector
    (first argument) and a row vector (second argument).

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

    Return a subset of a given matrix. 
    Given $matrix = Math::Matrix.new([[1,2,3][4,5,6],[7,8,9]]);
    A submatrix with one row and two columns:

    $matrix.submatrix(1,2);              # is [[1,2]]

    A submatrix from cell (0,1) on to left and down till cell (1,2):

    $matrix.submatrix(0,1,1,2);          # is [[2,3],[5,6]]

    When I just want cells in row 0 and 2 and colum 1 and 2 I use:

    $matrix.submatrix((0,2),(1..2));     # is [[2,3],[8,9]]

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

### perl

    Conversion into String like context that can reevaluated into the same
    object later. ( "Math::Matrix.new([[..,..,...],[...],...])" )

    my $clone = eval $matrix.perl;

### list-rows

    Returns a list of lists, reflecting the row-wise content of the matrix.

    Math::Matrix.new( [[1,2],[3,4]] ).list-rows ~~ ((1 2) (3 4))     # True

### list-columns

    Returns a list of lists, reflecting the row-wise content of the matrix.

    Math::Matrix.new( [[1,2],[3,4]] ).list-columns ~~ ((1 3) (2 4)) # True

### gist

    Limited tabular view for the shell output. Just cuts off excessive
    rows and columns. Implicitly called while:

    say $matrix;      # output when matrix has more than 100 cells

    1 2 3 4 5 ..
    3 4 5 6 7 ..
    ...

### full

    Full tabular view (all rows and columns) for the shell or file output.

    say $matrix.full;

Boolean Properties
------------------

### equal

    Checks two matrices for equality. They have to be of same size and
    every element of the first matrix on a particular position has to be equal
    to the element (on the same position) of the second matrix.

    if $matrixa.equal( $matrixb ) {
    if $matrixa ~~ $matrixb {

### is-square

    True if number of rows and colums are the same.

    if $matrix.is-square {

### is-invertible

    Is True if number of rows and colums are the same (is-square)
    and determinant is not zero.

### is-zero

    True if every cell has value of 0.

### is-identity

    True if every cell on the diagonal (where row index equals column index) is 1
    and any other cell is 0.

     Example:    1 0 0
                 0 1 0
                 0 0 1

### is-upper-triangular

    True if every cell below the diagonal (where row index is greater than column index) is 0.

     Example:    1 2 5
                 0 3 8
                 0 0 7

### is-lower-triangular

    True if every cell above the diagonal (where row index is smaller than column index) is 0.

     Example:    1 0 0
                 2 3 0
                 5 8 7

### is-diagonal

    True if only cells on the diagonal differ from 0.

     Example:    1 0 0
                 0 3 0
                 0 0 7

### is-diagonally-dominant

    True if cells on the diagonal have a bigger or equal absolute value than the
    sum of the other absolute values in the column.

    if $matrix.is-diagonally-dominant {
    $matrix.is-diagonally-dominant(:!strict)   # same thing (default)
    $matrix.is-diagonally-dominant(:strict)    # diagonal elements (DE) are stricly greater (>)
    $matrix.is-diagonally-dominant(:!strict, :along<column>) # default
    $matrix.is-diagonally-dominant(:strict,  :along<row>)    # DE > sum of rest row
    $matrix.is-diagonally-dominant(:!strict, :along<both>)   # DE >= sum of rest row and rest column

### is-symmetric

    Is True if every cell with coordinates x y has same value as the cell on y x.

    Example:    1 2 3
                2 5 4
                3 4 7

    if $matrix.is-symmetric {

### is-orthogonal

    if $matrix.is-orthogonal {

    Is True if the matrix multiplied (dotProduct) with its transposed version (T)
    is an identity matrix.

### is-positive-definite

    True if all main minors are positive

Numeric Properties
------------------

### size

    List of two values: number of rows and number of columns.

    say $matrix.size();
    my $dim = min $matrix.size();

### elems

    Number (count) of elements.

    say $matrix.elems();
    say +$matrix;                       # same thing

### density

    my $d = $matrix.density( );   

    Density is the percentage of cell which are not zero.

### trace

    my $tr = $matrix.trace( ); 

    The trace of a square matrix is the sum of the cells on the main diagonal.
    In other words: sum of cells which row and column value is identical.

### determinant, alias det

    If you see the columns as vectors, that describe the edges of a solid,
    the determinant of a square matrix tells you the volume of that solid.
    So if the solid is just in one dimension flat, the determinant is zero too.

    my $det = $matrix.determinant( );
    my $d = $matrix.det( );             # same thing
    my $d = |$matrix|;                  # operator shortcut

### rank

    my $r = $matrix.rank( );

    rank is the number of independent row or column vectors
    or also called independent dimensions
    (thats why this command is sometimes calles dim)

### kernel

    my $tr = $matrix.kernel( );
    kernel of matrix, number of dependent rows or columns

### norm

    my $norm = $matrix.norm( );           # euclidian norm (L2, p = 2)
    my $norm = ||$matrix||;               # operator shortcut to do the same
    my $norm = $matrix.norm(1);           # p-norm, L1 = sum of all cells
    my $norm = $matrix.norm(p:<4>,q:<3>); # p,q - norm, p = 4, q = 3
    my $norm = $matrix.norm(p:<2>,q:<2>); # Frobenius norm
    my $norm = $matrix.norm('max');       # maximum norm - biggest absolute value of a cell
    $matrix.norm('row-sum');              # row sum norm - biggest abs. value-sum of a row
    $matrix.norm('column-sum');           # column sum norm - same column wise

### condition

    my $c = $matrix.condition( );        

    Condition number of a matrix is L2 norm * L2 of inverted matrix.

Derivative Matrices
-------------------

### transposed, alias T

    return a new Matrix, which is the transposition of the current one

### inverted

    return a new Matrix, which is the inverted of the current one

### negated

    my $new = $matrix.negated();    # invert sign of all cells
    my $neg = - $matrix;            # works too

### reduced-row-echelon-form, alias rref

    my $rref = $matrix.reduced-row-echelon-form();
    my $rref = $matrix.rref();

    Return the reduced row echelon form of a matrix, a.k.a. row canonical form

Decompositions
--------------

### decompositionLU

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

### decompositionLUCrout

    my ($L, $U) = $matrix.decompositionLUCrout( );
    $L dot $U eq $matrix;                # True

    $L is a left triangular matrix and $R is a right one
    This decomposition works only on invertible matrices (square and full ranked).

### decompositionCholesky

    my $D = $matrix.decompositionCholesky( );  # $D is a left triangular matrix
    $D dot $D.T eq $matrix;                    # True 

    This decomposition works only on symmetric and definite positive matrices.

Matrix Operations
-----------------

### add

    my $sum = $matrix.add( $matrix2 );  # cell wise addition of 2 same sized matrices
    my $s = $matrix + $matrix2;         # works too

    my $sum = $matrix.add( $number );   # adds number from every cell 
    my $s = $matrix + $number;          # works too

### subtract

    my $diff = $matrix.subtract( $matrix2 );  # cell wise subraction of 2 same sized matrices
    my $d = $matrix - $matrix2;               # works too

    my $diff = $matrix.subtract( $number );   # subtracts number from every cell 
    my $sd = $matrix - $number;               # works too

### multiply

    my $product = $matrix.multiply( $matrix2 );  # cell wise multiplication of same size matrices
    my $p = $matrix * $matrix2;                  # works too

    my $product = $matrix.multiply( $number );   # multiply every cell with number
    my $p = $matrix * $number;                   # works too

### dotProduct

    my $product = $matrix1.dotProduct( $matrix2 )
    return a new Matrix, result of the dotProduct of the current matrix with matrix2
    Call be called throug operator ⋅ or dot , like following:
    my $c = $a ⋅ $b;
    my $c = $a dot $b;

    A shortcut for multiplication is the power - operator **
    my $c = $a **  3;               # same as $a dot $a dot $a
    my $c = $a ** -3;               # same as ($a dot $a dot $a).inverted
    my $c = $a **  0;               # created an right sized identity matrix

### map

    Like the built in map it iterates over all elements, running a code block.
    The results for a new matrix.

    say Math::Matrix.new( [[1,2],[3,4]] ).map(* + 1);    # prints

    2 3
    4 5

### reduce

    Like the built in reduce method, it iterates over all elements and joins
    them into one value, by applying the given operator or method
    to the previous result and the next element. I starts with the cell [0][0]
    and moving from left to right in the first row and continue with the first
    cell of the next row.

    Math::Matrix.new( [[1,2],[3,4]] ).reduce(&[+]);      # 10
    Math::Matrix.new( [[1,2],[3,4]] ).reduce(&[*]);      # 10

### reduce-rows

    Reduces (as described above) every row into one value, so the overall result
    will be a list. In this example we calculate the sum of all cells in a row:

    say Math::Matrix.new( [[1,2],[3,4]] ).reduce-rows(&[+]);     # prints (3, 7)

### reduce-columns

    Similar to reduce-rows, this method reduces each column to one value in the 
    resulting list:

    say Math::Matrix.new( [[1,2],[3,4]] ).reduce-columns(&[*]);  # prints (3, 8)

Operators
=========

    The Module overloads or uses a range of well and less known ops.
    +, -, * are commutative.

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

    my $dp  =  $a dot $b;            # dot product of two fitting matrices (cols a = rows b)
    my $dp  =  $a ⋅ $b;

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

