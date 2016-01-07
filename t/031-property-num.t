use Test;
use Math::Matrix;
plan 4;

subtest {
    plan 2;
    my $matrix = Math::Matrix.new([[1,2,5,4],[1,2,3,2],[9,8,4,1],[1,3,4,6]]);
    ok $matrix.determinant() == -72 , "Determinant of a Matrix";
    my $matrix2 = Math::Matrix.new([[1,2,5,4],[1,2,3,2],[9,8,4,1]]);
    dies-ok { $matrix2.determinant() } , "Non square matrix, no determinant";
}, "Determinant";

subtest {
    plan 2;
    my $matrix = Math::Matrix.new([[1,2,5,4],[1,2,3,2],[9,8,4,1],[1,3,4,6]]);
    ok $matrix.trace() == 13 , "Trace of a Matrix";
    my $matrix2 = Math::Matrix.new([[1,2,5,4],[1,2,3,2],[9,8,4,1]]);
    dies-ok { $matrix2.trace() } , "Non square matrix, no trace";
}, "Trace";

subtest {
    plan 4;
    my $zero = Math::Matrix.zero(3,4);
    my $identity = Math::Matrix.identity(3);
    my $diagonal = Math::Matrix.diagonal([1,2,3]);
    my $matrix = Math::Matrix.new([[1,2,3],[2,4,6],[3,6,9]]);

    ok $zero.rank == 0     ,"Rank of Zero Matrix";
    ok $identity.rank == 3 ,"Identity has full rank";
    ok $diagonal.rank == 3 ,"Diagonal has full rank";
    ok $matrix.rank == 1   ,"Custom Matrinx with larger Kernel has lesser rank";
}, "Rank";

subtest {
    plan 4;
    my $zero = Math::Matrix.zero(3,4);
    my $identity = Math::Matrix.identity(3);
    my $diagonal = Math::Matrix.diagonal([1,2,3]);
    my $matrix = Math::Matrix.new([[1,2,3],[2,4,6],[3,6,9]]);

    ok $zero.kernel == 3     ,"Zero Matrix has full kernel";
    ok $identity.kernel == 0 ,"Identity has no kernel";
    ok $diagonal.kernel == 0 ,"Diagonal has no kernel";
    ok $matrix.kernel == 2   ,"Custom Matrinx with larger Kernel has lesser rank";
}, "Kernel";
