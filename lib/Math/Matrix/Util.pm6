use v6.c;

unit role Math::Matrix::Util;

my subset PosInt of Int where * > 0;

method !rows       { ... }
method !clone-rows  { ... }
method !row-count    { ... }
method !column-count  { ... }

submethod !AoA-clone (@m) { [ map {[ map {$^cell.clone}, $^row.flat ]}, @m ]}

################################################################################
# checker
################################################################################

submethod !check-matrix-data (@m) {
    fail "Expect an Array or Array or List of Lists" unless (@m ~~ Array and all @m ~~ Array)
                                                         or (@m ~~ List and all @m ~~ List);
    fail "Expect the Array or List to have elements" if @m == 0 or @m[0] == 0;
    fail "All rows must contains the same number of elements" unless @m.elems == 1 or @m[0] == all @m[*];
    fail "All rows must contain only numeric values" unless all( @m[*;*] ) ~~ Numeric;
}

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
# data builder
################################################################################

submethod !zero-array( PosInt $rows, PosInt $cols = $rows ) {
    return [ [ 0 xx $cols ] xx $rows ];
}

submethod !identity-array( PosInt $size ) {
    my @identity;
    for ^$size X ^$size -> ($r, $c) { @identity[$r][$c] = ($r == $c ?? 1 !! 0) }
    return @identity;
}

################################################################################
# helper
################################################################################

method cofactor-sign( Int:D $row, Int:D $col ) { (-1) ** (($row+$col) mod 2) }
