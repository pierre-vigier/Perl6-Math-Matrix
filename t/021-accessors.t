use lib "lib";
use Test;
use Math::Matrix;
plan 5;


subtest {
    plan 4;
    my $matrix =   Math::Matrix.new([[4,0,1],[2,1,0],[2,2,3]]);

    ok $matrix.element(0,0) == 4, "first element";
    ok $matrix.element(2,1) == 2, "first element";
    dies-ok { my $element = $matrix.element(5,0); }, "Out of range row";
    dies-ok { my $element = $matrix.element(0,5); }, "Out of range column";

}, "Element";


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
    plan 18;
    my $matrix =   Math::Matrix.new([[4,0,1],[2,1,0],[2,2,3]]);
    my $identity = Math::Matrix.new-identity(3);
    my $morerows = Math::Matrix.new([[1,2],[3,4],[5,6]]);
    my $morecols = Math::Matrix.new([[6,7,8],[10,11,12]]);

    ok $matrix.diagonal() ~~ $matrix.diagonal(0),"main diagonal is default";
    ok $matrix.diagonal() ~~ (4,1,3),           "custom diagonal";
    ok $matrix.diagonal(-1) ~~ (0,0),          "short custom diagonal";
    ok $identity.diagonal() ~~ (1,1,1),       "identity diagonal";
    ok ($identity.diagonal(2) ~~ (0,)),      "short identity diagonal";
    
    ok $morerows.diagonal(0) ~~ (1,4),      "main diagonal of matrix with more rows";
    ok $morerows.diagonal(1) == (3,6),      "low diagonal of matrix with more rows";
    ok $morerows.diagonal(-1) ~~ (2,),      "high diagonal of matrix with more rows";
    ok $morecols.diagonal(0) ~~ (6,11),     "main diagonal of matrix with more cols";
    ok $morecols.diagonal(1) ~~ (10,),      "low diagonal of matrix with more cols";
    ok $morecols.diagonal(-1) ~~ (7,12),    "high diagonal of matrix with more cols";
    
    ok $identity.skew-diagonal() == (0,1,0),"main skew diagonal of identity matrix";
    ok $matrix.skew-diagonal(-1) == (2,0),  "upper skew diagonal";
    ok $matrix.skew-diagonal(2) == (3,),    "lower skew diagonal";
    
    dies-ok { Math::Matrix.new([[2,2,3]]).diagonal(1); },     "tried get diagonal outside of bound";
    dies-ok { $identity.diagonal(-3); },                      "tried get diagonal of identity outside of bound";
    dies-ok { Math::Matrix.new([[2,2,3]]).skew-diagonal(); }, "get skew diag only for square matrices";
    dies-ok { $identity.skew-diagonal(-3); },                 "tried get skew diagonal outside of bound";
}, "Diagonal";


subtest {
    plan 16;
    my $matrix   = Math::Matrix.new([[1,2,3,4],[5,6,7,8],[9,10,11,12]]);
    my $fsmatrix = Math::Matrix.new([[6,7,8],[10,11,12]]);
    my $lsmatrix = Math::Matrix.new([[1,2,3],[5,6,7]]);
    my $rehashed = Math::Matrix.new([[11,9,12],[3,1,4]]);
    my $dropfrow = Math::Matrix.new([[5,6,7,8],[9,10,11,12]]);
    my $dropfcol = Math::Matrix.new([[2,3,4],[6,7,8],[10,11,12]]);

    dies-ok { $matrix.submatrix(10,1); },                    "demanded rows are out of range";
    dies-ok { $matrix.submatrix(1,5); },                     "demanded colums are out of range";
    dies-ok { $matrix.submatrix( rows =>   -1..7, columns => 2..8) },   "demanded submatrix goes out of scope due second element";
    dies-ok { $matrix.submatrix( rows => 1.1 ..2, columns => 2.. 3) },  "reject none int indices";
    dies-ok { $matrix.submatrix( rows =>  (2..4), columns => (1..5)) }, "rows and colums are out of range";

    ok $matrix.submatrix(0,0)                              ~~ $fsmatrix, "submatrix built by removing first element";
    ok $matrix.submatrix(2,3)                              ~~ $lsmatrix, "submatrix built by removing last element";
    ok $matrix.submatrix( rows => 1..2, columns => 1 .. 3) ~~ $fsmatrix, "submatrix with range syntax";
    ok $matrix.submatrix( rows => 1..2, columns => 1 .. *) ~~ $fsmatrix, "submatrix with range syntax using * aka Inf";
    ok $matrix.submatrix( rows => (1,2),columns => (1...3))~~ $fsmatrix, "simple submatrix created with list syntax";
    ok $matrix.submatrix( rows => (2,0),columns => (2,0,3))~~ $rehashed, "rehashed submatrix using list syntax";
    ok $matrix.submatrix( )                                ~~ $matrix  , "submatrix with no arguments is matrix itself";
    
    ok $matrix.submatrix( rows => 1..*)                    ~~ $dropfrow, "submatrix with range syntax omiting column parameter";
    ok $matrix.submatrix( columns => 1..3)                 ~~ $dropfcol, "submatrix with range syntax omiting row parameter";
    ok $matrix.submatrix( rows => (1,2))                   ~~ $dropfrow, "submatrix with list syntax omiting column parameter";
    ok $matrix.submatrix( columns => (1,2,3))              ~~ $dropfcol, "submatrix with list syntax omiting row parameter";
    
}, "Submatrix";

