use Test;
use Math::Matrix;
plan 11;

lives-ok { my $matrix = Math::Matrix.new([[1,2],[3,4]]); }, "Able to create a materix";
dies-ok { my $matrix = Math::Matrix.new([[1,2],[1,2,3]]); }, "Different nuber of elements per line";
dies-ok { my $matrix = Math::Matrix.new(); }, "Constructor need params";

my $matrixa = Math::Matrix.new([[1,2],[3,4]]);
my $matrixb = Math::Matrix.new([[1,2],[3,4]]);
my $matrixc = Math::Matrix.new([[8,8],[8,8]]);

ok $matrixa.equal( $matrixb ), " equal method working";
ok $matrixa == $matrixb , " == operator working";
ok $matrixa eq $matrixb , " eq operator working";

nok $matrixa.equal( $matrixc ) , "Non equal matrices, with equal method";
nok $matrixa == $matrixc , "Non equal matrices, with ==";
nok $matrixa eq $matrixc , "Non equal matrices, with eq";
ok $matrixa != $matrixc , "Non equal matrices, with !=";
ok $matrixa ne $matrixc , "Non equal matrices, with ne";
