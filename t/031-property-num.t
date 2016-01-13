use Test;
use Math::Matrix;
plan 7;


subtest {
    plan 4;
    my $zero = Math::Matrix.zero(3,3);
    my $matrixa = Math::Matrix.new([[1,2],[3,4]]);
    my $matrixb = Math::Matrix.new([[1,2],[3,4],[5,6]]);

    ok $zero.size eqv    (3,3),  "Right size";
    ok $matrixa.size eqv (2,2),  "Right size too";
    nok $matrixa.size eqv (5,5), "Wrong size";
    ok $matrixb.size eqv (3,2),  "Non square matrix, right size";
}, "Size";

subtest {
    plan 5;
    my $zero = Math::Matrix.zero(3,3);
    my $identity = Math::Matrix.identity(3);
    my $diagonal = Math::Matrix.diagonal([1,2,3]);
    my $matrix = Math::Matrix.new([[1,2,5,4],[1,2,3,2],[9,8,4,1],[1,3,4,6]]);
    my $matrix2 = Math::Matrix.new([[1,2,5,4],[1,2,3,2],[9,8,4,1]]);

    dies-ok { $matrix2.determinant() } , "Non square matrix, no determinant";
    ok $zero.determinant() == 0 , "Determinant of zero matrix is 0";
    ok $identity.determinant() == 1 , "Determinant of identity matrix is 1";
    ok $diagonal.determinant() == 6 , "det of diagonal matrix is product of diagonal elements";
    ok $matrix.determinant() == -72 , "Determinant of a Matrix";
}, "Determinant";

subtest {
    plan 2;
    my $matrix = Math::Matrix.new([[1,2,5,4],[1,2,3,2],[9,8,4,1],[1,3,4,6]]);
    ok $matrix.trace() == 13 , "Trace of a Matrix";
    my $matrix2 = Math::Matrix.new([[1,2,5,4],[1,2,3,2],[9,8,4,1]]);
    dies-ok { $matrix2.trace() } , "Non square matrix, no trace";
}, "Trace";

subtest {
    plan 3;
    my $zero = Math::Matrix.zero(3,4);
    my $identity = Math::Matrix.identity(3);
    my $matrix = Math::Matrix.new([[1,2,3],[2,4,6],[3,6,9]]);

    ok $zero.density == 0         ,"Zero matrix has density of 0";
    ok $identity.density == 1/3   ,"Identity matrix has density of 1/size";
    ok $matrix.density == 1       ,"full matrix has density of 1";
}, "Density";


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
    ok $matrix.kernel == 2   ,"Custom Matrix with larger Kernel has lesser rank";
}, "Kernel";

subtest {
    plan 20;
    my $zero = Math::Matrix.zero(3,4);
    my $identity = Math::Matrix.identity(3);
    my $diagonal = Math::Matrix.diagonal([1,2,3]);
    my $matrix = Math::Matrix.new([[1,2,3],[2,4,6],[3,6,9]]);

    dies-ok { $zero.norm(0) }       ,"there is no 0 norm";
    dies-ok { $zero.norm(1,0) }     ,"there is no n,0 norm";
    dies-ok { $zero.norm(0.1) }     ,"p accepts only whole numbers";
    dies-ok { $zero.norm(1,0.1) }   ,"q accepts only whole numbers";
    ok $zero.norm == 0              ,"Zero matrix is 0 in any norm";
    ok $identity.norm == 3          ,"Identity matrix norm equals rank";
    ok $diagonal.norm == 6          ,"Norm of diagonal matrix is equal trace in euclid space";
    ok $zero.norm(1,1) == 0         ,"Zero matrix is 0 in any norm";
    ok $matrix.norm(1,1) == 36      ,"1,1 norm is just sum of elements";
    ok $zero.norm(2,2) == 0         ,"Zero matrix is 0 in 2,2 norm too";
    ok $diagonal.norm(2,2) == sqrt(14),"Frobenius norm";

    ok $zero.norm('max') == 0       ,"max norm of zero == 0";
    ok $matrix.norm('max') == 9     ,"max norm";
    ok ($matrix *3).norm('max')== 9*3,"max norm is homogenic";
    ok $zero.norm('rowsum') == 0    ,"row sum norm of zero == 0";
    ok $matrix.norm('rowsum') == 18 ,"row sum norm";
    ok ($matrix *3).norm('rowsum') == 18*3,"row sum norm is homogenic";
    ok $zero.norm('columnsum') == 0 ,"column sum norm of zero == 0";
    ok $matrix.norm('columnsum') == 18,"column sum norm";
    ok ($matrix *3).norm('columnsum') == 18*3,"column sum norm is homogenic";

}, "Norm";
