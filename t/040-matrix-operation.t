use Test;
use Math::Matrix;
plan 9;

subtest {
    plan 2;
    my $matrix   = Math::Matrix.new([[1,2],[3,4]]);
    my $expected = Math::Matrix.new([[1,3],[2,4]]);

    ok $matrix.T eq $expected, "Transposition result correct";
    ok $matrix.T.T eq $matrix, "Double tranposition does nothing";
}, "Tranposition";

subtest {
    plan 8;
    my $identity = Math::Matrix.identity(3);
    my $diagonal = Math::Matrix.diagonal([1,2,3]);
    my $matrixa  = Math::Matrix.new([[1,2,3],[2,4,6],[3,6,9]]);
    my $matrixb  = Math::Matrix.new([[1,2],[3,4]]);
    my $expectb  = Math::Matrix.new([[-2, 1],[1.5, -0.5]]);
    my $matrixc  = Math::Matrix.new([[1,1,0],[0,1,1],[1,0,1]]);
    my $expectc  = Math::Matrix.new([[0.5,-.5,0.5],[0.5,.5,-0.5],[-0.5,0.5,0.5]]);
    my $expectd  = Math::Matrix.new([[1,0,0],[0,0.5,0],[0,0,1/3]]);
 
    dies-ok {Math::Matrix.zero(3,4).inverted},   "only square matrices can be inverted";
    dies-ok {$matrixa.inverted},       "only none singular matrices can be inverted";
    ok $matrixb.inverted eq $expectb,  "Inversion works correctly";
    ok $matrixb.inverted.inverted eq $matrixb, "Double Inversion does nothing";
    ok $identity.inverted eq $identity,"Inverted identity is identity";
    ok $matrixc.inverted  eq $expectc, "Inversion works correctly";
    ok $diagonal.inverted eq $expectd, "Inversion works correctly for diagonal";
    ok $matrixb ** -1 eq $expectb,     "inverting by operator works too";
}, "Inversion";

subtest {
    plan 8;
    my $a = Math::Matrix.new( [[1,2,3],[4,5,6]] );
    my $b = Math::Matrix.new( [[7,8],[9,10],[11,12]] );
    my $matrix   = Math::Matrix.new([[1,2],[3,4]]);
    my $identity = Math::Matrix.identity(2);

    ok $a.dotProduct( $b ) eqv Math::Matrix.new([[58,64],[139,154]]), "Simple multiplication check";
    ok ($a ⋅ $b) eqv Math::Matrix.new([[58,64],[139,154]]),   "Simple multiplication check with ⋅ operator";
    ok ($a dot $b) eqv Math::Matrix.new([[58,64],[139,154]]), "Simple multiplication check with ⋅ operator, texas form";
    ok $matrix ** 0 eq $identity,                             "times one means no multiplication";
    ok $matrix ** 1 eq $matrix,                               "times one means no multiplication";
    ok $matrix ** 2 eq $matrix dot $matrix,                   "power operator works too";

    my $c = Math::Matrix.new( [[7,8],[9,10],[11,12],[13,14]] );
    dies-ok { $a ⋅ $c } , "Matrices can't be multiplied, first matrix column count should be equal to second matrix row count";
    dies-ok { $a.dotProduct( $c ) } , "Matrices can't be multiplied, first matrix column count should be equal to second matrix row count";
}, "Dot Product";

subtest {
    plan 2;
    my $matrix = Math::Matrix.new([[1,2],[3,4]]);
    ok $matrix.negative() eqv Math::Matrix.new([[ -1 , -2 ],[ -3 , -4 ]]), "Negative of a matrix";
    ok $matrix.negative().negative() eqv $matrix, "Double negative does nothing";
}, "Negative";

subtest {
    plan 2;
    my $matrix = Math::Matrix.new([[1,2],[3,4]]);
    my $matrix2 = Math::Matrix.new([[4,3],[2,1]]);
    my $expected = Math::Matrix.new([[5,5],[5,5]]);
    ok $matrix.add( $matrix2 ) eqv $expected, "Sum of matrices";
    ok $matrix + $matrix2 eqv $expected, "Sum of matrices using + operator";
}, "Sum of matrices";

subtest {
    plan 2;
    my $matrix = Math::Matrix.new([[1,2],[3,4]]);
    my $matrix2 = Math::Matrix.new([[4,3],[2,1]]);
    my $expected = Math::Matrix.new([[ -3 , -1 ],[ 1 , 3 ]]);
    ok $matrix.subtract( $matrix2 ) eqv $expected, "Substraction of matrices";
    ok $matrix - $matrix2 eqv $expected, "Substraction of matrices using - operator";
}, "Substraction of matrices";

subtest {
    plan 2;
    my $matrix = Math::Matrix.new([[1,2],[3,4]]);
    my $matrix2 = Math::Matrix.new([[4,3],[2,1]]);
    my $expected = Math::Matrix.new([[ 4 , 6 ],[ 6 , 4 ]]);
    say $matrix.multiply( $matrix2 );
    ok $matrix.multiply( $matrix2 ) eqv $expected, "Multiplication of matrices (element by element)";
    ok $matrix * $matrix2 eqv $expected, "Multiplication of matrices using * operator";
}, "Multiplication of matrices";

subtest {
    plan 3;
    my $matrix = Math::Matrix.new([[1,1],[1,1]]);
    my $expected = Math::Matrix.new([[ 2.2 , 2.2 ],[ 2.2 , 2.2 ]]);
    ok $matrix.multiply( 2.2 ) eqv $expected, "multiplication with real working";
    ok $matrix * 2.2 eqv $expected, "multiplication with real working with operator *";
    ok 2.2 * $matrix eqv $expected, "multiplication with real working with operator *, reverse args";
}, "Multiply Matrix with number";

subtest {
    plan 2;
    my $matrix = Math::Matrix.new([[4,0,1],[2,1,0],[2,2,3]]);
    my $expectedL = Math::Matrix.new([[4,0,0],[2,1,0],[2,2,7/2]]);
    my $expectedU = Math::Matrix.new([[1,0,1/4],[0,1,-1/2],[0,0,1]]);

    my ($L, $U) = $matrix.decopositionLUCrout();
    ok ( $L ~~ $expectedL and $U ~~ $expectedU ) , "L and U are correct";
    ok ($L dot $U) ~~ $matrix, "LU is equal to original matrix";
}, "Decompostition";
