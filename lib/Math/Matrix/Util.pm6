use v6.c;
use Math::Matrix::Type;

unit role Math::Matrix::Util;

method !rows       { ... }
method !clone-rows  { ... }
method !row-count    { ... }
method !column-count  { ... }

################################################################################
# checker
################################################################################

submethod !check-row-index       (Int $row) {
    fail X::OutOfRange.new(:what<Row Index>,
                           :got($row),
                           :range(0 .. self!row-count - 1)) unless 0 <= $row < self!row-count
}

submethod !check-column-index    (Int $col) {
    fail X::OutOfRange.new(:what<Column Index>,
                           :got($col),
                           :range(0 .. self!column-count - 1)) unless 0 <= $col < self!column-count
}
submethod !check-index (Int $row, Int $col) {
    self!check-row-index($row);
    self!check-column-index($col);
}

submethod !check-row-indices       ( @row) {
    fail "Row index has to be an Int." unless all(@row) ~~ Int;
    fail X::OutOfRange.new( :what<Row index>,
                            :got(@row),
                            :range("0..{self!row-count -1 }")) unless 0 <= all(@row) < self!row-count;
}
submethod !check-column-indices    ( @col) {
    fail "Column index has to be an Int." unless all(@col) ~~ Int;
    fail X::OutOfRange.new( :what<Column index>,
                            :got(@col),
                            :range("0..{self!column-count -1 }")) unless 0 <= all(@col) < self!column-count;
}
submethod !check-indices (@row, @col) {
    self!check-row-indices(@row);
    self!check-column-indices(@col);
}

################################################################################
# helper
################################################################################

method cofactor-sign( Int:D $row, Int:D $col ) { (-1) ** (($row+$col) mod 2) }
