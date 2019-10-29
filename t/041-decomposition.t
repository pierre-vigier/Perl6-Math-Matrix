use lib "lib";
use Test;
use Math::Matrix;
plan 2;

subtest {
    plan 16;
    my $mat = Math::Matrix.new([[7, 3, 7, 1, 1, 4],
                                [9, 7, 6, 1, 9, 1],
                                [9, 6, 2, 5, 5, 6],
                                [6, 0, 3, 5, 1, 3],
                                [0, 5, 0, 0, 5, 7],
                                [4, 2, 7, 6, 1, 9]]);
    my $matrix = Math::Matrix.new([[4,0,1],[2,1,0],[2,2,3]]);
    my $expectedL = Math::Matrix.new([[4,0,0],[2,1,0],[2,2,7/2]]);
    my $expectedU = Math::Matrix.new([[1,0,1/4],[0,1,-1/2],[0,0,1]]);
    my ($L, $D, $U, $P);

    my ($L1, $U1) = $mat.LU-decomposition();
    ok $L1 dot $U1 ~~ $mat,              "LU = A";
    say $U1 dot $L1;
    ok $L1.is-triangular(:lower, :unit), "L is lower unit triangular";
    ok $U1.is-triangular(:upper),        "U is upper triangular";
    nok $U1.is-triangular(:unit),        "U is not unit";

    my ($L2, $U2) = $mat.LU-decomposition( :Crout );
    ok $L2 dot $U2 ~~ $mat,              "LU = A Crout";
    ok $L2.is-triangular(:lower ),       "L is lower triangular";
    ok $U2.is-triangular(:upper, :unit), "U is upper unit triangular";
    nok $L2.is-triangular(:unit),        "L is not unit";
    dies-ok {$mat.LU-decomposition( :Crout, :diagonal )},  "attributes :Crout and :diagonal are mutually exclusive";

die "good";
    ( $L, $U, $P ) = $matrix.LU-decomposition();
    ok $L dot $U ~~ $P dot $matrix, "LU = PA";

    ($L, $U) = $matrix.decompositionLUCrout();
    ok ( $L ~~ $expectedL and $U ~~ $expectedU ) , "L and U are correct";
    ok ($L dot $U) ~~ $matrix, "LU is equal to original matrix";

}, "LU";


subtest {
    plan 8;

    my $zero = Math::Matrix.new-zero(3,4);
    my $identity = Math::Matrix.new-identity(3);
    my $diagonal = Math::Matrix.new-diagonal([1,4,9]);
    my $diagonalD = Math::Matrix.new-diagonal([1,2,3]);
    my $simple = Math::Matrix.new([[1,3],[3,25]]);
    my $simpleD = Math::Matrix.new([[1,0],[3,4]]);

    dies-ok {$zero.Cholesky-decomposition},            "no decomposition of none square matrices";
    dies-ok {Math::Matrix.new([[1,1,3],[5,2,1],[5,3,4]]).Cholesky-decomposition},
                                                       'no decomposition of none diagonal dominant matrices';
    ok $identity.Cholesky-decomposition ~~ $identity,  "decomposed identity is identity";
    ok $diagonal.Cholesky-decomposition ~~ $diagonalD, "in decomposed diagonal matrix cell values get squared";
    ok $simple.Cholesky-decomposition ~~ $simpleD,     "simple custom Cholesky decomposition";
    ok $simple.Cholesky-decomposition(:!diagonal) ~~ $simpleD,"format without diagonal is default";
    my ($G) = $simple.Cholesky-decomposition();
    ok $G dot $G.T ~~ $simple,                         "Cholesky without diagonal matrix is a working decomposition";
    my ($L, $D) = $simple.Cholesky-decomposition(:diagonal);
    ok $L dot $D dot $L.T ~~ $simple,                  "Cholesky with a diagonal matrix is a working decomposition";
}, "Choleski";
