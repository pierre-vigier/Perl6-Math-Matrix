use lib "lib";
use Test;
use Math::Matrix;
plan 5;


subtest {
    plan 4;
    my $matrix =   Math::Matrix.new([[4,0,1],[2,1,0],[2,2,3]]);

    ok $matrix.cell(0,0) == 4, "first cell";
    ok $matrix.cell(2,1) == 2, "first cell";
    dies-ok { my $cell = $matrix.cell(5,0); }, "Out of range row";
    dies-ok { my $cell = $matrix.cell(0,5); }, "Out of range column";

}, "Cell";

subtest {
    plan 2;
    my $matrix =   Math::Matrix.new([[4,0,1],[2,1,0],[2,2,3]]);

    ok $matrix.row(1) == (2,1,0), "got second row";
    dies-ok { $matrix.row(5) },   "tried none existing row";
}, "Row";

subtest {
    plan 2;
    my $matrix =   Math::Matrix.new([[4,0,1],[2,1,0],[2,2,3]]);

    ok $matrix.column(1) == (0,1,2), "got second column";
    dies-ok { $matrix.column(5) },   "tried none existing column";
}, "Column";

subtest {
    plan 3;
    my $matrix =   Math::Matrix.new([[4,0,1],[2,1,0],[2,2,3]]);
    my $identity = Math::Matrix.new-identity(3);

    ok $matrix.diagonal() ~~ (4,1,3), "custom diagonal";
    ok $identity.diagonal() ~~ (1,1,1), "identity diagonal";
    dies-ok { Math::Matrix.new([[2,2,3]]).diagonal(); }, "tried get diagonal of none square matrix";
}, "Diagonal";


subtest {
    plan 10;
    my $matrix   = Math::Matrix.new([[1,2,3,4],[5,6,7,8],[9,10,11,12]]);
    my $fsmatrix = Math::Matrix.new([[6,7,8],[10,11,12]]);
    my $lsmatrix = Math::Matrix.new([[1,2,3],[5,6,7]]);
    my $expected = Math::Matrix.new([[6,7,8],[10,11,12]]);

    dies-ok { $matrix.submatrix(10,1); },            "demanded rows are out of range";
    dies-ok { $matrix.submatrix(1,5); },             "demanded colums are out of range";
    dies-ok { $matrix.submatrix(-1..7, 2..8); },     "demanded submatrix goes out of scope due second cell";
    dies-ok { $matrix.submatrix(1.1 ..2, 2.. 3); },  "reject none int indices";
    dies-ok { $matrix.submatrix((2..4),(1..5)); },   "rows and colums are out of range";

    ok $matrix.submatrix(0,0) ~~ $fsmatrix,          "submatrix built by removing first cell";
    ok $matrix.submatrix(2,3) ~~ $lsmatrix,          "submatrix built by removing last cell";
    ok $matrix.submatrix( 1..2, 1.. 3) ~~ $expected,  "submatrix wiht start and end cell";
    ok $matrix.submatrix( 1..2, 1.. 3) ~~ $expected,  "submatrix wiht start and end cell";
    ok $matrix.submatrix((1,2),(1...3))~~ $expected, "Simple submatrix";
    
}, "Submatrix";

