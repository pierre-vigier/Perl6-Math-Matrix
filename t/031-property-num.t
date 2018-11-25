use lib "lib";
use Test;
use Math::Matrix;
plan 9;

subtest {
    plan 4;
    my $zero = Math::Matrix.new-zero(3,3);
    my $matrixa = Math::Matrix.new([[1,2],[3,4]]);
    my $matrixb = Math::Matrix.new([[1,2],[3,4],[5,6]]);

    ok $zero.size eqv    (3,3),  "Right size";
    ok $matrixa.size eqv (2,2),  "Right size too";
    nok $matrixa.size eqv (5,5), "Wrong size";
    ok $matrixb.size eqv (3,2),  "Non square matrix, right size";
}, "Size";

subtest {
    plan 3;
    my $zero = Math::Matrix.new-zero(3,4);
    my $identity = Math::Matrix.new-identity(3);
    my $matrix = Math::Matrix.new([[1,2,3],[2,4,6],[3,6,9]]);

    ok $zero.density == 0         ,"Zero matrix has density of 0";
    ok $identity.density == 1/3   ,"Identity matrix has density of 1/size";
    ok $matrix.density == 1       ,"full matrix has density of 1";
}, "Density";

subtest {
    plan 15;
    my $zero = Math::Matrix.new-zero(3,4);
    my $identity = Math::Matrix.new-identity(3);
    my $matrix = Math::Matrix.new([[1,2,3],[2,4,6],[3,6,9]]);
    my $matrixb = Math::Matrix.new([[1,0],[3,4],[5,6]]);
    my $matrixc = Math::Matrix.new([[1,2,3],[0,4,5]]);

    ok $zero.upper-bandwith == 0    ,"Zero matrix has upper bandwith of 0";
    ok $zero.lower-bandwith == 0    ,"Zero matrix has lower bandwith of 0";
    ok $zero.bandwith == 0          ,"Zero matrix has bandwith of 0";
    ok $identity.upper-bandwith == 0,"Identity matrix has upper bandwith of 0";
    ok $identity.lower-bandwith == 0,"Identity matrix has lower bandwith of 0";
    ok $identity.bandwith == 0      ,"Identity matrix has bandwith of 0";
    ok $matrix.upper-bandwith == 2,  "full matrix has upper bandwith of 2";
    ok $matrix.lower-bandwith == 2,  "full matrix has lower bandwith of 2";
    ok $matrix.bandwith == 2        ,"full matrix has bandwith of 2";
    ok $matrixb.upper-bandwith == 0, "custom matrix has upper bandwith of 0";
    ok $matrixb.lower-bandwith == 2, "custom matrix has lower bandwith of 2";
    ok $matrixb.bandwith == 2     ,  "custom matrix has bandwith of 2";
    ok $matrixc.upper-bandwith == 2, "custom mirror matrix has upper bandwith of 2";
    ok $matrixc.lower-bandwith == 0, "custom mirror matrix has lower bandwith of 0";
    ok $matrixc.bandwith == 2     ,  "custom mirror matrix has bandwith of 2";
}, "Bandwith";


subtest {
    plan 2;
    my $matrix = Math::Matrix.new([[1,2,5,4],[1,2,3,2],[9,8,4,1],[1,3,4,6]]);
    ok $matrix.trace() == 13 , "Trace of a Matrix";
    my $matrix2 = Math::Matrix.new([[1,2,5,4],[1,2,3,2],[9,8,4,1]]);
    dies-ok { $matrix2.trace() } , "Non square matrix, no trace";
}, "Trace";

subtest {
    plan 7;
    my $zero = Math::Matrix.new-zero(3,3);
    my $identity = Math::Matrix.new-identity(3);
    my $diagonal = Math::Matrix.new-diagonal([1,2,3]);
    my $matrix = Math::Matrix.new([[1,2,5,4],[1,2,3,2],[9,8,4,1],[1,3,4,6]]);
    my $matrix2 = Math::Matrix.new([[1,2,5,4],[1,2,3,2],[9,8,4,1]]);

    dies-ok { $matrix2.determinant() } , "Non square matrix, has no determinant";
    ok $zero.determinant() == 0 , "Determinant of zero matrix is 0";
    ok $identity.determinant() == 1 , "Determinant of identity matrix is 1";
    ok $diagonal.determinant() == 6 , "det of diagonal matrix is product of diagonal elements";
    ok $matrix.determinant() == -72 , "Determinant of a Matrix";

    my $a = Math::Matrix.new([[7, 3, 7, 1, 1, 4], [9, 7, 6, 1, 9, 1], [9, 6, 2, 5, 5, 6], [6, 0, 3, 5, 1, 3], [0, 5, 0, 0, 5, 7], [4, 2, 7, 6, 1, 9]]);
    ok $a.det == -33618, "6x6 matrix determinant is correct (use Decomposition behind the scene)";
    
    ok( ( ｜ $matrix ｜  == -72), 'unicode determinant operator');
}, "Determinant";


subtest {
    plan 4;
    my $zero = Math::Matrix.new-zero(3,4);
    my $identity = Math::Matrix.new-identity(3);
    my $diagonal = Math::Matrix.new-diagonal([1,2,3]);
    my $matrix = Math::Matrix.new([[1,2,3],[2,4,6],[3,6,9]]);

    ok $zero.rank == 0     ,"Rank of Zero Matrix";
    ok $identity.rank == 3 ,"Identity has full rank";
    ok $diagonal.rank == 3 ,"Diagonal has full rank";
    ok $matrix.rank == 1   ,"Custom Matrinx with larger nullity has lesser rank";
}, "Rank";

subtest {
    plan 4;
    my $zero = Math::Matrix.new-zero(3,4);
    my $identity = Math::Matrix.new-identity(3);
    my $diagonal = Math::Matrix.new-diagonal([1,2,3]);
    my $matrix = Math::Matrix.new([[1,2,3],[2,4,6],[3,6,9]]);

    ok $zero.nullity == 3     ,"Zero matrix has full nullity";
    ok $identity.nullity == 0 ,"Identity has no nullity";
    ok $diagonal.nullity == 0 ,"Diagonal has no nullity";
    ok $matrix.nullity == 2   ,"Custom matrix with larger nullity has lesser rank";
}, "Nullity";

subtest {
    plan 29;
    my $zero = Math::Matrix.new-zero(3,4);
    my $identity = Math::Matrix.new-identity(3);
    my $diagonal = Math::Matrix.new-diagonal([1,2,3]);
    my $matrix = Math::Matrix.new([[1,2,3],[2,4,6],[3,6,9]]);
    my $m1 = Math::Matrix.new([[1]]);
    my $m2 = Math::Matrix.new([[1,2],[3,4]]);

    dies-ok { $zero.norm(0) }         ,"there is no 0 norm";
    dies-ok { $zero.norm(1,0) }       ,"there is no n,0 norm";
    dies-ok { $zero.norm(0.1) }       ,"p accepts only whole numbers";
    dies-ok { $zero.norm(1,0.1) }     ,"q accepts only whole numbers";
    ok $zero.norm == 0                ,"Zero matrix is 0 in any norm";
    ok $identity.norm == sqrt(3)      ,"Identity matrix norm equals rank";
    ok $diagonal.norm == sqrt(14)     ,"Norm of diagonal matrix is equal trace in euclid space";
    ok $diagonal.norm(:p<2>) == sqrt(14), "2,1 Norm with one default value";
    ok $diagonal.norm(:p<2>,:q<1>) == 6,"2,1 Norm with no default value";
    ok $zero.norm(:p<1>,:q<1>) == 0   ,"Zero matrix is 0 in any norm";
    ok $matrix.norm(:p<1>,:q<1>)== 36 ,"1,1 norm is just sum of elements";
    ok $zero.norm(:p<2>,:q<2>) == 0   ,"Zero matrix is 0 in 2,2 norm too";
    ok $diagonal.norm(:p<2>,:q<2>) == sqrt(14),"Frobenius norm";

    ok $zero.norm('max') == 0         ,"max norm of zero == 0";
    ok $matrix.norm('max') == 9       ,"max norm";
    ok ($matrix *3).norm('max')== 9*3 ,"max norm is homogenic";
    ok $zero.norm('row-sum') == 0     ,"row sum norm of zero == 0";
    ok $matrix.norm('row-sum') == 18  ,"row sum norm";
    ok ($matrix *3).norm('row-sum') == 54,"row sum norm is homogenic";
    ok $zero.norm('column-sum') == 0  ,"column sum norm of zero == 0";
    ok $matrix.norm('column-sum') == 18,"column sum norm";
    ok ($matrix *3).norm('column-sum') == 54,"column sum norm is homogenic";

    ok ($diagonal dot $matrix).norm <= $diagonal.norm * $matrix.norm, "Cauchy-Schwarz inequality for L2 norm";
    ok ($diagonal dot $matrix).norm(:p<2>,:q<3>) <= $diagonal.norm(:p<2>,:q<3>) * $matrix.norm(:p<2>,:q<3>), "Cauchy-Schwarz inequality for 2,3 norm";
    ok ($diagonal dot $matrix).norm('max') <= $diagonal.norm('max') * $matrix.norm('max'),  "Cauchy-Schwarz inequality for maximum norm";
    ok ($diagonal dot $matrix).norm('row-sum') <= $diagonal.norm('row-sum') * $matrix.norm('row-sum'),  "Cauchy-Schwarz inequality for rowsum norm";
    ok ($diagonal dot $matrix).norm('column-sum') <= $diagonal.norm('column-sum') * $matrix.norm('column-sum'),  "Cauchy-Schwarz inequality for columnsum norm";

   ok ‖ $m1 ‖ == 1, 'norm op on simplest matrix';
   ok ‖ $m2 ‖ == 5.477225575051661, 'norm op on default matrix';


}, "Norm";


subtest {
    my $matrixa = Math::Matrix.new([[1,2],[3,4]]);
    my $matrixm = Math::Matrix.new([[Bool,2.3],[3-i, 4.1.FatRat]]);
    my $matrixr = Math::Matrix.new([[4e-3,2.3],[12, 4.1.FatRat]]);
    ok $matrixa.narrowest-element-type ~~ Int, "got narrowest type of default example correct";
    ok $matrixa.widest-element-type ~~ Int, "got widest type of default example correct";
    ok $matrixm.narrowest-element-type ~~ Bool, "got narrowest type of mixed matrix correct";
    ok $matrixm.widest-element-type ~~ Complex, "got widest type of mixed matrix correct";
    ok $matrixr.narrowest-element-type ~~ Int, "got narrowest type of mostly rational matrix correct";
    ok $matrixr.widest-element-type ~~ FatRat, "got widest type of mostly rational typed matrix correct";
}, 'Element Type';
