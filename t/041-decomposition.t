use lib "lib";
use Test;
use Math::Matrix;
plan 3;

subtest {
    plan 1;

    my $matrix = Math::Matrix.new([[7, 3, 7, 1, 1, 4], [9, 7, 6, 1, 9, 1], [9, 6, 2, 5, 5, 6], [6, 0, 3, 5, 1, 3], [0, 5, 0, 0, 5, 7], [4, 2, 7, 6, 1, 9]]);
    my ( $L, $U, $P ) = $matrix.decompositionLU();
    ok $L dot $U ~~ $P dot $matrix, "LU = PA";
}, "LU";


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
    plan 8;

    my $zero = Math::Matrix.new-zero(3,4);
    my $identity = Math::Matrix.new-identity(3);
    my $diagonal = Math::Matrix.new-diagonal([1,4,9]);
    my $diagonalD = Math::Matrix.new-diagonal([1,2,3]);
    my $simple = Math::Matrix.new([[1,3],[3,25]]);
    my $simpleD = Math::Matrix.new([[1,0],[3,4]]);

    dies-ok {$zero.decomposition-cholesky},            "no decomposition of none square matrices";
    dies-ok {Math::Matrix.new([[1,1,3],[5,2,1],[5,3,4]]).decomposition-cholesky},
                                                       'no decomposition of none diagonal dominant matrices';
    ok $identity.decomposition-cholesky ~~ $identity,  "decomposed identity is identity";
    ok $diagonal.decomposition-cholesky ~~ $diagonalD, "in decomposed diagonal matrix cell values get squared";
    ok $simple.decomposition-cholesky ~~ $simpleD,     "simple custom cholesky decomposition";
    ok $simple.decomposition-cholesky(:!diagonal) ~~ $simpleD,"format 'G' is default";
    my ($G) = $simple.decomposition-cholesky();
    ok $G dot $G.T ~~ $simple,                         "cholesky GG is a working decomposition";
    my ($L, $D) = $simple.decomposition-cholesky(:diagonal);
    ok $L dot $D dot $L.T ~~ $simple,                  "cholesky LD is a working decomposition";
}, "Choleski";
