use Test;
use Math::Matrix;
plan 2;

subtest {
    plan 2;
    my $matrix =   Math::Matrix.new([[4,0,1],[2,1,0],[2,2,3]]);
    my $identity = Math::Matrix.new-identity(3);

    ok $matrix.diagonal() ~~ (4,1,3), "custom diagonal";
    ok $identity.diagonal() ~~ (1,1,1), "identity diagonal";
}, "Diagonal";


subtest {
    plan 2;
    my $matrix   = Math::Matrix.new([[1,2,3,4],[5,6,7,8],[9,10,11,12]]);
    my $expected = Math::Matrix.new([[6, 7, 8], [10, 11, 12]]);

    ok $matrix.submatrix(0,0) ~~ $expected, "Simple submatrix with scalar parameter";
    ok $matrix.submatrix( (1,2) , (1...3) ) ~~ $expected, "Simple submatrix";
}, "Submatrix";

