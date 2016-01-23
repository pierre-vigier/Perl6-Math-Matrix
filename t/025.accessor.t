use Test;
use Math::Matrix;
plan 1;

subtest {
    plan 1;
    my $matrix   = Math::Matrix.new([[1,2,3,4],[5,6,7,8],[9,10,11,12]]);
    my $expected = Math::Matrix.new([[6, 7, 8], [10, 11, 12]]);

    ok $matrix.submatrix( (1,2) , (1...3) ) ~~ $expected, "Simple submatrix";
}, "Submatrix";

