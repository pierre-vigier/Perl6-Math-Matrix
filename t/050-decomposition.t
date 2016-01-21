use Test;
use Math::Matrix;
plan 2;

subtest {
    plan 2;
    my $matrix = Math::Matrix.new([[4,0,1],[2,1,0],[2,2,3]]);
    my $expectedL = Math::Matrix.new([[4,0,0],[2,1,0],[2,2,7/2]]);
    my $expectedU = Math::Matrix.new([[1,0,1/4],[0,1,-1/2],[0,0,1]]);

    my ($L, $U) = $matrix.decompositionLUCrout();
    ok ( $L ~~ $expectedL and $U ~~ $expectedU ) , "L and U are correct";
    ok ($L dot $U) ~~ $matrix, "LU is equal to original matrix";

}, "LUCrout";


subtest {
    plan 4;

    my $zero = Math::Matrix.new-zero(3,4);
    my $identity = Math::Matrix.new-identity(3);
    my $diagonal = Math::Matrix.new-diagonal([1,4,9]);
    my $diagonalD = Math::Matrix.new-diagonal([1,2,3]);
    my $simple = Math::Matrix.new([[1,3],[3,25]]);
    my $simpleD = Math::Matrix.new([[1,0],[3,4]]);

    dies-ok {$zero.decompositionCholeski},           "no decomposition of none square matrices";
    ok $identity.decompositionCholeski ~~ $identity, "decomposed identity is identity";
    ok $diagonal.decompositionCholeski ~~ $diagonalD,"in decomposed diagonal matrix cell values get squared";
    ok $simple.decompositionCholeski ~~ $simpleD,    "simple custom choleski decomposition";
    
    
}, "Choleski";
