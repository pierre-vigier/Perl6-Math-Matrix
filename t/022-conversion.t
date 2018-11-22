use lib "lib";
use Test;
use Math::Matrix;
plan 23;

my $matrixi = Math::Matrix.new([[1,2],[3,4]]);
my $matrixr = Math::Matrix.new([[ 1.1, 2.2 ],[ 3.3 , 4.4 ]]);
my $matrixc = Math::Matrix.new([[ 1.1+i, 2.2-i ],[ 3.3+2i , 4.4-3.4i ]]);


ok $matrixi == $matrixi             , ".equal method works";
my $from-perl = EVAL($matrixi.perl);
ok $from-perl ~~ $matrixi           , ".perl result can be evaled in a similar object";

ok  $matrixi.Str().WHAT ~~ Str        , "Method Str should return a String";
is  $matrixi.Str(), "1 2\n3 4"        , "value is correct in Str context ";
is  ~$matrixi, "1 2\n3 4"             , "content is correct in string context by prefix op";
ok  $matrixi.Numeric ~~ Numeric       , "method .Numeric returns right type";
is  +$matrixi, sqrt(30)               , "content is correct in numeric context by prefix op";
ok   $matrixi.Bool ~~ Bool            , "method .Bool returns right type";
is  ?$matrixi, True                   , "content is correct in bool context by prefix op";
ok   $matrixi.list ~~ List            , "method .List returns correct type";
ok   $matrixi.list ~~ (1,2,3,4)       , "method .List returns correct content";
ok  |$matrixi == (1,2,3,4)            , "correct list context conversion with prefix op";
ok   $matrixi.Hash ~~ Hash            , "method .Hash return correct type";
ok  %$matrixi == { 0=> {0=>1, 1=>2}, 1=> {0=>3, 1=>4}}, "correct hash context conversion with prefix op";

is ~$matrixr, "1.1 2.2\n3.3 4.4"    , "correct content of real values in string context";
is ~$matrixc, "1.1+1i 2.2-1i\n3.3+2i 4.4-3.4i", "correct content of complex values in Str context";

ok $matrixi.list == (1, 2, 3, 4)    , "list context";
ok $matrixi.list-rows == ((1, 2), (3, 4)), "vertical list of lists context";
ok $matrixi.list-columns == ((1,3),(2,4)), "horizontal list of lists context";
ok $matrixi.Range == 1..4,                 "Range context";

ok $matrixi.Array == [[1, 2], [3, 4]]                  , "Array context";
ok $matrixi.Hash == { 0=>{0=>1,1=>2}, 1=>{0=>3, 1=>4}} , "Hash context";

ok Math::Matrix.gist eq "(Math::Matrix)"               , "gist of type object";
