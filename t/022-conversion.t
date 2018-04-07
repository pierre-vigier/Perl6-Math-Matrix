use Test;
use Math::Matrix;
plan 13;

my $matrixi = Math::Matrix.new([[1,2],[3,4]]);
my $matrixr = Math::Matrix.new([[ 1.1, 2.2 ],[ 3.3 , 4.4 ]]);
my $matrixc = Math::Matrix.new([[ 1.1+i, 2.2-i ],[ 3.3+2i , 4.4-3.4i ]]);


my $from-perl = EVAL($matrixi.perl);
ok $from-perl ~~ $matrixi          , ".perl result can be evaled in a similar object";

ok $matrixi.Str().WHAT ~~ Str      , "Method Str should return a String";
is $matrixi.Str(), "1 2 | 3 4"     , "value is correct in Str context ";
is ~$matrixi, "1 2 | 3 4"          , "content is correct in string context by prefix op";
is +$matrixi, 4                    , "content is correct in numeric context by prefix op";
is ?$matrixi, True                 , "content is correct in bool context by prefix op";

is ~$matrixr, "1.1 2.2 | 3.3 4.4"  , "correct content of real values in string context";
is ~$matrixc, "1.1+1i 2.2-1i | 3.3+2i 4.4-3.4i", "correct content of complex values in Str context";

ok $matrixi.list == (1, 2, 3, 4)   , "list context";
ok $matrixi.list-rows == ((1, 2), (3, 4)), "vertical list of lists context";
ok $matrixi.list-columns == ((1,3),(2,4)), "horizontal list of lists context";

ok $matrixi.Array == [[1, 2], [3, 4]]    , "Array context";

ok Math::Matrix.gist eq "(Math::Matrix)" , "gist of type object";
