use Test;
use Math::Matrix;

plan 12;

my $matrix = Math::Matrix.new([[1,2],[3,4]]);

ok $matrix.T.T eq $matrix, "Double Tranposition does nothing";

my $a = Math::Matrix.new( [[1,2,3],[4,5,6]] );
my $b = Math::Matrix.new( [[7,8],[9,10],[11,12]] );

ok $a.multiply( $b ) eq Math::Matrix.new([[58,64],[139,154]]), "Simple multiplication check";
ok ($a ⋅ $b) eq Math::Matrix.new([[58,64],[139,154]]), "Simple multiplication check with ⋅ operator";
ok ($a dot $b) eq Math::Matrix.new([[58,64],[139,154]]), "Simple multiplication check with ⋅ operator, texas form";

ok $matrix.negative() eq Math::Matrix.new([[ -1 , -2 ],[ -3 , -4 ]]), "Negative of a matrix";

$matrix = Math::Matrix.new([[1,2],[3,4]]);
my $matrix2 = Math::Matrix.new([[4,3],[2,1]]);
my $expected = Math::Matrix.new([[5,5],[5,5]]);
ok $matrix.add( $matrix2 ) eq $expected, "Sum of matrices";
ok $matrix + $matrix2 eq $expected, "Sum of matrices using + operator";

$expected = Math::Matrix.new([[ -3 , -1 ],[ 1 , 3 ]]);
ok $matrix.substract( $matrix2 ) eq $expected, "Substraction of matrices";
ok $matrix - $matrix2 eq $expected, "Substraction of matrices using - operator";

$matrix = Math::Matrix.new([[1,1],[1,1]]);
$expected = Math::Matrix.new([[ 2.2 , 2.2 ],[ 2.2 , 2.2 ]]);
ok $matrix.multiply( 2.2 ) eq $expected, "multiplication with real working";
ok $matrix * 2.2 eq $expected, "multiplication with real working with operator *";
ok 2.2 * $matrix eq $expected, "multiplication with real working with operator *, reverse args";
