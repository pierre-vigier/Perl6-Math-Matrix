use Test;
use Math::Matrix;
plan 12;

my $matrixa = Math::Matrix.new([[1,2],[3,4]]);
my $matrixr = Math::Matrix.new([[ 1.1, 2.2 ],[ 3.3 , 4.4 ]]);

my $from-perl = EVAL($matrixa.perl);
ok $from-perl ~~ $matrixa          , ".perl result can be evaled in a similar object";

ok $matrixa.Str().WHAT ~~ Str      , "Method Str should return a String";
is $matrixa.Str(), "1 2 3 4"       , "value is correct in Str context ";
is ~$matrixa, "1 2 3 4"            , "content is correct in string context by prefix op";
is +$matrixa, 4                    , "content is correct in numeric context by prefix op";
is ?$matrixa, True                 , "content is correct in bool context by prefix op";

is ~$matrixr, "1.1 2.2 3.3 4.4"    , "correct content of real values in string context";

ok $matrixa.list == (1, 2, 3, 4)   , "list context";
ok $matrixa.list-rows == ((1, 2), (3, 4)), "vertical list of lists context";
ok $matrixa.list-columns == ((1,3),(2,4)), "horizontal list of lists context";

ok $matrixa.Array == [[1, 2], [3, 4]]    , "Array context";

ok Math::Matrix.gist eq "(Math::Matrix)" , "gist of type object";
