use Test;
use Math::Matrix;
plan 23;

lives-ok { my $matrix = Math::Matrix.new([[1,2],[3,4]]); }  , "Able to create a materix";
dies-ok  { my $matrix = Math::Matrix.new([[1,2],[1,2,3]]); }, "Different nuber of elements per line";
dies-ok  { my $matrix = Math::Matrix.new(); }               , "Constructor need params";
dies-ok  { my $matrix = Math::Matrix.new([[1,2],[3,"a"]]); }, "All elements have to be Numeric";

my $matrixa = Math::Matrix.new([[1,2],[3,4]]);
my $matrixb = Math::Matrix.new([[1,2],[3,4]]);
my $matrixc = Math::Matrix.new([[8,8],[8,8]]);
my $matrixd = Math::Matrix.new([[ 1.0 , 2.0 ],[ 3.0 , 4.0 ]]);

is $matrixa.cell(0,0) , 1, "Accessor cell is working";
is $matrixd.cell(1,1) , 4.0, "Accessor cell is working with Real";
dies-ok { my $cell = $matrixa.cell(5,0); }, "Out of range row";
dies-ok { my $cell = $matrixa.cell(0,5); }, "Out of range column";

ok $matrixa.equal( $matrixb ), " equal method working";
ok $matrixa ~~ $matrixb ,     " ~~ operator working";

nok $matrixa.equal( $matrixc ) , "Non equal matrices, with equal method";
nok $matrixa ~~ $matrixc , "Non equal matrices, with ~~";

ok $matrixa.equal( $matrixd ), " equal method working";
ok $matrixa ~~ $matrixd ,     " ~~ operator working";


my $data =     [[1,3],[3,25]];
my $samedata = [[1,3],[3,25]];
my $dataMatrix = Math::Matrix.new($data);;
my $samedataMatrix = Math::Matrix.new($samedata);;
$data[0][0] = 0;
ok $dataMatrix ~~ $samedataMatrix,  " no bleed from input data to matrix";



my $zero = Math::Matrix.new-zero(3,4);
my $expectz = Math::Matrix.new([[0,0,0,0],[0,0,0,0],[0,0,0,0]]);
ok $zero ~~ $expectz, "Get zero matrix";

my $identity = Math::Matrix.new-identity(3);
my $expected = Math::Matrix.new([[1,0,0],[0,1,0],[0,0,1]]);
ok $identity ~~ $expected, "Get identity matrix";

my $diagonal = Math::Matrix.new-diagonal([1,2,3]);
my $expectd   = Math::Matrix.new([[1,0,0],[0,2,0],[0,0,3]]);
ok $diagonal ~~ $expectd, "Get diagonal matrix";
#TODO: reinstate test either in success or failure
my $diagonal2 = Math::Matrix.new-diagonal( 1, 2, 3 );
ok  $diagonal2 ~~ $expectd, "Get diagonal matrix";

my $product = Math::Matrix.new-vector-product([1,2,3],[2,3,4]);
my $pexpect = Math::Matrix.new([[2,3,4],[4,6,8],[6,9,12]]);
ok $product.equal( $pexpect ), "matrix construction by vector product";

ok $matrixa.Str().WHAT ~~ Str, "Method Str should return a String";
is $matrixa.Str(), "[[1 2] [3 4]]", "Value is correct";

my $from-perl = EVAL($matrixa.perl);
ok $from-perl ~~ $matrixa, ".perl result can be evaled in a similar object";
