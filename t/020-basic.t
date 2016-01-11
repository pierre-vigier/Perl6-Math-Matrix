use Test;
use Math::Matrix;
plan 12;

lives-ok { my $matrix = Math::Matrix.new([[1,2],[3,4]]); }, "Able to create a materix";
dies-ok { my $matrix = Math::Matrix.new([[1,2],[1,2,3]]); }, "Different nuber of elements per line";
dies-ok { my $matrix = Math::Matrix.new(); }, "Constructor need params";

my $matrixa = Math::Matrix.new([[1,2],[3,4]]);
my $matrixb = Math::Matrix.new([[1,2],[3,4]]);
my $matrixc = Math::Matrix.new([[8,8],[8,8]]);
my $matrixd = Math::Matrix.new([[ 1.0 , 2.0 ],[ 3.0 , 4.0 ]]);


ok $matrixa.equal( $matrixb ), " equal method working";
ok $matrixa ~~ $matrixb ,     " ~~ operator working";

nok $matrixa.equal( $matrixc ) , "Non equal matrices, with equal method";
nok $matrixa ~~ $matrixc , "Non equal matrices, with ~~";

ok $matrixa.equal( $matrixd ), " equal method working";
ok $matrixa ~~ $matrixd ,     " ~~ operator working";


my $zero = Math::Matrix.zero(3,4);
my $expectz = Math::Matrix.new([[0,0,0,0],[0,0,0,0],[0,0,0,0]]);
ok $zero eqv $expectz, "Get zero matrix";

my $identity = Math::Matrix.identity(3);
my $expected = Math::Matrix.new([[1,0,0],[0,1,0],[0,0,1]]);
ok $identity eqv $expected, "Get identity matrix";

my $diagonal = Math::Matrix.diagonal([1,2,3]);
my $expectd   = Math::Matrix.new([[1,0,0],[0,2,0],[0,0,3]]);
ok $diagonal eqv $expectd, "Get diagonal matrix";
#TODO: reinstate test either in success or failure
##my $diagonal2 = Math::Matrix.diagonal( 1, 2, 3 );
