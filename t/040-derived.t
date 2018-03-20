use Test;
use Math::Matrix;
plan 5;

subtest {
    plan 3;
    my $matrix = Math::Matrix.new([[1,2],[3,4]]);
    ok $matrix.negated() ~~ Math::Matrix.new([[ -1 , -2 ],[ -3 , -4 ]]), "Negative of a matrix";
    ok $matrix.negated().negated() ~~ $matrix, "Double negative does nothing";
    ok - $matrix ~~ Math::Matrix.new([[ -1 , -2 ],[ -3 , -4 ]]), "negate by op";
}, "Negation";

subtest {
    plan 3;
    my $matrix = Math::Matrix.new([[1,2],[3,4]]);
    my $cmatrix = Math::Matrix.new([[1+i,2],[3-2i,4]]);
    my $ccmatrix = Math::Matrix.new([[1-i,2],[3+2i,4]]);
    ok $matrix.conjugated() ~~ $matrix, "conjugation on Int matrix is identity";
    ok $cmatrix.conj().conj() ~~ $cmatrix, "Double conjugation is identity";
    ok $cmatrix.conjugated() ~~ $ccmatrix, "does conjugation right";
}, "Conjugation";

subtest {
    plan 2;
    my $matrix   = Math::Matrix.new([[1,2],[3,4]]);
    my $expected = Math::Matrix.new([[1,3],[2,4]]);

    ok $matrix.T ~~ $expected, "Transposition result correct";
    ok $matrix.T.T ~~ $matrix, "Double tranposition does nothing";
}, "Tranposition";

subtest {
    plan 8;
    my $identity = Math::Matrix.new-identity(3);
    my $diagonal = Math::Matrix.new-diagonal([1,2,3]);
    my $matrixa  = Math::Matrix.new([[1,2,3],[2,4,6],[3,6,9]]);
    my $matrixb  = Math::Matrix.new([[1,2],[3,4]]);
    my $expectb  = Math::Matrix.new([[-2, 1],[1.5, -0.5]]);
    my $matrixc  = Math::Matrix.new([[1,1,0],[0,1,1],[1,0,1]]);
    my $expectc  = Math::Matrix.new([[0.5,-.5,0.5],[0.5,.5,-0.5],[-0.5,0.5,0.5]]);
    my $expectd  = Math::Matrix.new([[1,0,0],[0,0.5,0],[0,0,1/3]]);

    dies-ok {Math::Matrix.zero(3,4).inverted},   "only square matrices can be inverted";
    dies-ok {$matrixa.inverted},       "only none singular matrices can be inverted";
    ok $matrixb.inverted ~~ $expectb,  "Inversion works correctly";
    ok $matrixb.inverted.inverted ~~ $matrixb, "Double Inversion does nothing";
    ok $identity.inverted ~~ $identity,"Inverted identity is identity";
    ok $matrixc.inverted  ~~ $expectc, "Inversion works correctly";
    ok $diagonal.inverted ~~ $expectd, "Inversion works correctly for diagonal";
    ok $matrixb ** -1 ~~ $expectb,     "inverting by operator works too";
}, "Inversion";

subtest {
    plan 2;
    my $matrix = Math::Matrix.new(
        [[1, 2, -1, -4],
        [2, 3, -1, -11],
        [-2, 0, -3, 22]]
    );
    my $expected = Math::Matrix.new([
        [1, 0, 0, -8],
        [0, 1, 0,  1],
        [0, 0, 1, -2]
    ]);
    ok $matrix.reduced-row-echelon-form() ~~ $expected, "Rref is correct";
    ok $matrix.rref() ~~ $expected, "Rref is correct, using shortcut";
}, "row echelon";
