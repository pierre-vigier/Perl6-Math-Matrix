use lib "lib";
use Test;
use Math::Matrix;
plan 32;

dies-ok  { my $matrix = Math::Matrix.new() }                 , "Constructor need params";
dies-ok  { my $matrix = Math::Matrix.new( [] ) }             , "Empty row Array is not enough";
dies-ok  { my $matrix = Math::Matrix.new( [[],[]]) }         , "Empty columns Arrays are not enough";
dies-ok  { my $matrix = Math::Matrix.new( ()) }              , "Empty row List is not enough";
dies-ok  { my $matrix = Math::Matrix.new( ((),())) }         , "Empty columns Lists are not enough";
dies-ok  { my $matrix = Math::Matrix.new( "" ) }             , "Empty String as Input is not enough";
dies-ok  { my $matrix = Math::Matrix.new( "\n\n" ) }         , "String with empty lines as Input is not enough";
dies-ok  { my $matrix = Math::Matrix.new( [[1,2],[1,2,3]]) } , "Different nuber of elements per line";
dies-ok  { my $matrix = Math::Matrix.new( [[1,2],[3,"a"]]) } , "All elements have to be Numeric";
lives-ok { my $matrix = Math::Matrix.new( [[1,2],[3,4]]) }   , "Able to create a int matrix with Array of Array syntax";
lives-ok { my $matrix = Math::Matrix.new( [[.1,2.11111],[3/5,4e-2]]) }, "created a rational matrix";
lives-ok { my $matrix = Math::Matrix.new( [[1,2],[3,4+i]]) } , "Able to create a complex matrix";
lives-ok { my $matrix = Math::Matrix.new( [[True, False],[False,True]]) }, "created a Bool matrix";
lives-ok { my $matrix = Math::Matrix.new( ((1,2),(3,4))) }   , "Able to create matrix with List of List syntax";
lives-ok { my $matrix = Math::Matrix.new( "1 2 \n 3 4") }    , "Able to create a int matrix with Str syntax";

my $matrixa = Math::Matrix.new([[1,2],[3,4]]);
ok $matrixa ~~ Math::Matrix        , "object was created of right type";
dies-ok  { my $matrixa.new([[1,2],[1,2,3]]); }, "can not call new on existing matrix";
ok $matrixa ~~ Math::Matrix.new(((1,2),(3,4))), "AoA and LoL syntax work the same";
ok $matrixa ~~ Math::Matrix.new("1 2 \n 3 4"), "AoA and Str syntax work the same";


my $data   =   [[1,3],[3,25]];
my $samedata = [[1,3],[3,25]];
my $dataMatrix = Math::Matrix.new($data);;
my $samedataMatrix = Math::Matrix.new($samedata);;
$data[0][0] = 0;
ok $dataMatrix ~~ $samedataMatrix  , "no bleed from input data to matrix";


my $matrixb = Math::Matrix.new([[1,2],[3,4]]);
my $matrixc = Math::Matrix.new([[8,8],[8,8]]);
my $matrixd = Math::Matrix.new([[ 1.0, 2.0 ],[ 3.0 , 4.0 ]]);

ok $matrixa.equal( $matrixb ), "equal method working";
ok $matrixa ~~ $matrixb      , "~~ operator working";

nok $matrixa.equal( $matrixc), "Non equal matrices, with equal method";
nok $matrixa ~~ $matrixc     , "Non equal matrices, foud via ~~";

ok $matrixa.equal( $matrixd) , "equal method working";
ok $matrixa ~~ $matrixd      , "~~ operator working";

my $zero = Math::Matrix.new-zero(3,4);
my $expectz = Math::Matrix.new([[0,0,0,0],[0,0,0,0],[0,0,0,0]]);
ok $zero ~~ $expectz, "Get zero matrix";
is ?$zero, False    , "zero matrix is false in bool context by prefix op";

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
