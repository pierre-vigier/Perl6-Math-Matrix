use Test;
use Math::Matrix;
plan 53;

my $matrixa = Math::Matrix.new([[1,2],[3,4]]);
my $matrixc = Math::Matrix.new([[8,8],[8,8]]);
my $matrixd = Math::Matrix.new([[1,2,3],[4,5,6]]);

my $matrixh = Math::Matrix.new([[1,2+i],[2-i,4]]);
my $matrixu = Math::Matrix.new([[0,i],[i,0]]);

my $zero = Math::Matrix.new-zero(3,4);
my $identity = Math::Matrix.new-identity(3);
my $diagonal = Math::Matrix.new-diagonal(1,2,3);
my $ut = Math::Matrix.new([[1,2,3],[0,5,6],[0,0,6]]);
my $lt = Math::Matrix.new([[1,0,0],[4,5,0],[4,5,6]]);
my $symmetric = Math::Matrix.new([[ 1, 2, 3, 4 ],
                                  [ 2, 1, 5, 6 ],
                                  [ 3, 5, 1, 7 ],
                                  [ 4, 6, 7, 1 ]]);


ok $matrixa.is-square,    "Is a square matrix";
nok $matrixd.is-square,   "Is not a square matrix";

ok $zero.is-zero,         "Is a zero matrix";
nok $identity.is-zero,    "Is not a zero matrix";

ok $ut.is-upper-triangular,       "Is an upper triangular matrix";
ok $diagonal.is-upper-triangular, "Diagonal are upper triangular";
nok $matrixa.is-upper-triangular, "Is not an upper triangular matrix";
nok $lt.is-upper-triangular,      "lower is no upper triangular matrix";

ok $lt.is-lower-triangular,       "Is an lower triangular matrix";
ok $diagonal.is-lower-triangular, "Diagonal are lower triangular";
nok $matrixc.is-lower-triangular, "Is not an lower diagonal matrix";
nok $ut.is-lower-triangular,      "upper is no lower triangular matrix";

my $almostidentity = Math::Matrix.new([ [ 1, 0, 0 ], [ 0, 1, 0 ] ]);
ok $identity.is-identity,        "Is an identity matrix";
nok $diagonal.is-identity,       "Is not an identity matrix";
nok $almostidentity.is-identity, "Is not an identity matrix";

nok $almostidentity.is-diagonal, "Is not an diagonal matrix";
ok  $identity.is-diagonal,       "Is an diagonal matrix";
ok  $diagonal.is-diagonal,       "Diagonal is an diagonal matrix";
nok $lt.is-diagonal,             "Lower triangular matrix is no an diagonal matrix";
nok $ut.is-diagonal,             "Upper triangular matrix is no an diagonal matrix";

nok $matrixa.is-diagonally-dominant, 'not diagonally dominant matrix';
ok  $matrixc.is-diagonally-dominant, 'its diagonally dominant when all values are same';
nok $matrixc.is-diagonally-dominant(:strict),   'not strictly diagonally dominant when all values are same';
ok  $identity.is-diagonally-dominant(:!strict), 'identity is always diagonally dominant';
ok  $identity.is-diagonally-dominant(:strict),  'I is always strictly diagonally dominant';
ok  $diagonal.is-diagonally-dominant(:strict, :along<column>),'a diagonal matrix is col wise strictly diagonally dominant';
ok  $diagonal.is-diagonally-dominant(:strict, :along<row>),   'a diagonal matrix is row wise strictly diagonally dominant';
ok  $diagonal.is-diagonally-dominant(:strict, :along<both>),  'a diagonal matrix is always strictly diagonally dominant';
nok $lt.is-diagonally-dominant(:!strict, :along<row>), 'this lower triangular matrix is not diagonally rowwise dominant';
nok $ut.is-diagonally-dominant(:!strict, :along<row>), 'this upper triangular matrix is not diagonally rowwise dominant';

ok $diagonal.is-symmetric, "Is a symmetric matrix";
ok $symmetric.is-symmetric,"Is a symmetric matrix";
nok $matrixa.is-symmetric, "Is not a symmetric matrix";

ok Math::Matrix.new-zero(3).is-antisymmetric, "Zero matrix is antisymmetric";
ok Math::Matrix.new([[0,1],[-1,0]]).is-antisymmetric, "Special matrix is antisymmetric";
nok $symmetric.is-antisymmetric,              "Symmetric is not antisymmetric matrix";
nok $matrixa.is-antisymmetric,                "Default 1 to 4 matrix is not antisymmetric";

ok $diagonal.is-self-adjoint, "diagonal matrix is also hermetian";
ok $matrixh.is-self-adjoint,  "this special matrix is hermetian";
nok $ut.is-self-adjoint,      "a triangular matrix can not be hermetian";

ok $identity.is-unitary,      "Identity matrix is unitary";
ok $matrixu.is-unitary,       "special matrix is unitary";

ok $identity.is-orthogonal, "Is a orthogonal matrix";
nok $matrixa.is-orthogonal, "Is not a orthogonal matrix";

ok $identity.is-invertible, "Identity matrix is invertible";
ok $diagonal.is-invertible, "Diagonal matrix is invertible";
ok $diagonal.is-invertible, "A full ranked square matrix is invertible";
nok $zero.is-invertible,    "Zero matrix is not invertible";
nok $matrixd.is-invertible, "Matrix with defect Is not invertible";

ok $identity.is-positive-definite, "Identity matrix is positive definite.";
ok $identity.is-positive-semidefinite, "Identity matrix is positive semidefinite.";
ok Math::Matrix.new([[2,-1,0],[-1,2,-1],[0,-1,2]]).is-positive-definite, "Special matrix is positive definite.";
nok $zero.is-positive-definite,    "zero matrix is not positive definite.";