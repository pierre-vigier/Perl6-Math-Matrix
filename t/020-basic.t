use Test;
use Math::Matrix;

plan 2;

my $matrix = Math::Matrix.new([[1,2],[3,4]]);

ok $matrix.T.T eq $matrix, "Double Tranposition does nothing";

my $a = Math::Matrix.new( [[1,2,3],[4,5,6]] );
my $b = Math::Matrix.new( [[7,8],[9,10],[11,12]] );

ok $a.multiply( $b ) eq Math::Matrix.new([[58,64],[139,154]]), "Simple multiplication check";
