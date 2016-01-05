use Test;
use Math::Matrix;
plan 13;

lives-ok { my $matrix = Math::Matrix.new([[1,2],[3,4]]); }, "Able to create a materix";
dies-ok { my $matrix = Math::Matrix.new([[1,2],[1,2,3]]); }, "Different nuber of elements per line";
dies-ok { my $matrix = Math::Matrix.new(); }, "Constructor need params";

my $matrixa = Math::Matrix.new([[1,2],[3,4]]);
my $matrixb = Math::Matrix.new([[1,2],[3,4]]);
my $matrixc = Math::Matrix.new([[8,8],[8,8]]);
my $matrixd = Math::Matrix.new([[1,2,3],[4,5,6]]);

ok $matrixa.equal( $matrixb ), " equal method working";
ok $matrixa eqv $matrixb , " eqv operator working";

nok $matrixa.equal( $matrixc ) , "Non equal matrices, with equal method";
nok $matrixa eqv $matrixc , "Non equal matrices, with eqv";


my $identity = Math::Matrix.identity(3);
my $expected = Math::Matrix.new([[1,0,0],[0,1,0],[0,0,1]]);
ok $identity eqv $expected, "Get identity matrix";

my $diagonal = Math::Matrix.diagonal(1,2,3);
my $expect   = Math::Matrix.new([[1,0,0],[0,2,0],[0,0,3]]);
ok $identity eqv $expect, "Get diagonal matrix";


ok $matrixa.is-square() , "Is a square matrix";
nok $matrixd.is-square(), "Is not a square matrix";

ok $diagonal.is-symmetric(), "Is a symmetric matrix";
nok $matrixa.is-symmetric(), "Is not a symmetric matrix";
