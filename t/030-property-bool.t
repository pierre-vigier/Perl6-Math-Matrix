use Test;
use Math::Matrix;
plan 12;

my $matrixa = Math::Matrix.new([[1,2],[3,4]]);
my $matrixc = Math::Matrix.new([[8,8],[8,8]]);
my $matrixd = Math::Matrix.new([[1,2,3],[4,5,6]]);

my $zero = Math::Matrix.zero(3,4);
my $identity = Math::Matrix.identity(3);
my $diagonal = Math::Matrix.diagonal([1,2,3]);

ok $zero.size ==    (3,4),  "Right size";
ok $matrixa.size == (2,2),  "Right size too";

ok $matrixa.is-square,    "Is a square matrix";
nok $matrixd.is-square,   "Is not a square matrix";

ok $zero.is-zero,         "Is a zero matrix";
nok $identity.is-zero,    "Is not a zero matrix";

ok $identity.is-identity,  "Is a identity matrix";
nok $diagonal.is-identity, "Is not a identity matrix";

ok $diagonal.is-symmetric, "Is a symmetric matrix";
nok $matrixa.is-symmetric, "Is not a symmetric matrix";

ok $identity.is-orthogonal, "Is a orthogonal matrix";
nok $matrixa.is-orthogonal, "Is not a orthogonal matrix";
