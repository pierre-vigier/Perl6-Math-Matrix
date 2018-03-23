use v6.c;

role Math::Matrix::Operators;

################################################################################
# end of structural matrix operations - start self made operators 
################################################################################

=begin pod
=head1 Operators

    The Module overloads or uses a range of well and less known ops.
    +, -, * and ~~ are commutative.

    my $a   = +$matrix               # Num context, amount (count) of cells
    my $b   = ?$matrix               # Bool context, True if any cell has a none zero value
    my $str = ~$matrix               # String context, matrix content as data structure

    $matrixa ~~ $matrixb             # check if both have same size and they are cell wise equal

    my $sum =  $matrixa + $matrixb;  # cell wise sum of two same sized matrices
    my $sum =  $matrix  + $number;   # add number to every cell

    my $dif =  $matrixa - $matrixb;  # cell wise difference of two same sized matrices
    my $dif =  $matrix  - $number;   # subtract number from every cell
    my $neg = -$matrix               # negate value of every cell

    my $p   =  $matrixa * $matrixb;  # cell wise product of two same sized matrices
    my $sp  =  $matrix  * $number;   # multiply number to every cell

    my $tp  =  $a x $b;              # tensor product 
    my $tp  =  $a ⊗ $b;              # tensor product, unicode alias

    my $dp  =  $a dot $b;            # dot product of two fitting matrices (cols a = rows b)
    my $dp  =  $a ⋅ $b;              # dot product, unicode alias

    my $c   =  $a **  3;             # $a to the power of 3, same as $a dot $a dot $a
    my $c   =  $a ** -3;             # alias to ($a dot $a dot $a).inverted
    my $c   =  $a **  0;             # creats an right sized identity matrix

     | $matrix |                     # determinant
    || $matrix ||                    # Euclidean (L2) norm

=end pod


multi sub infix:<+>(Math::Matrix $a, Math::Matrix $b --> Math::Matrix:D ) is export {
    $a.add($b);
}

multi sub infix:<+>(Math::Matrix $a, Real $r --> Math::Matrix:D ) is export {
    $a.add( $r );
}
multi sub infix:<+>(Real $r, Math::Matrix $a --> Math::Matrix:D ) is export {
    $a.add( $r );
}

multi sub infix:<->(Math::Matrix $a, Math::Matrix $b --> Math::Matrix:D ) is export {
    $a.subtract($b);
}
multi sub infix:<->(Math::Matrix $a, Real $r --> Math::Matrix:D ) is export {
    $a.add( -$r );
}
multi sub infix:<->(Real $r, Math::Matrix $a --> Math::Matrix:D ) is export {
    $a.negated.add( $r );
}

multi sub prefix:<->(Math::Matrix $a --> Math::Matrix:D ) is export {
    $a.negated();
}

multi sub infix:<⊗>( Math::Matrix $a, Math::Matrix $b  --> Math::Matrix:D ) is looser(&infix:<*>) is export {
    $a.tensorProduct( $b );
}

multi sub infix:<x>( Math::Matrix $a, Math::Matrix $b  --> Math::Matrix:D ) is looser(&infix:<*>) is export {
    $a.tensorProduct( $b );
}

multi sub infix:<⋅>( Math::Matrix $a, Math::Matrix $b where { $a!column-count == $b!row-count} --> Math::Matrix:D ) is looser(&infix:<*>) is export {
    $a.dotProduct( $b );
}

multi sub infix:<dot>(Math::Matrix $a, Math::Matrix $b --> Math::Matrix:D ) is looser(&infix:<*>) is export {
    $a.dotProduct( $b );
}

multi sub infix:<*>(Math::Matrix $a, Real $r --> Math::Matrix:D ) is export {
    $a.multiply( $r );
}

multi sub infix:<*>(Real $r, Math::Matrix $a --> Math::Matrix:D ) is export {
    $a.multiply( $r );
}

multi sub infix:<*>(Math::Matrix $a, Math::Matrix $b  where { $a!row-count == $b!row-count and $a!column-count == $b!column-count} --> Math::Matrix:D ) is export {
    $a.multiply( $b );
}

multi sub infix:<**>(Math::Matrix $a where { $a.is-square }, Int $e --> Math::Matrix:D ) is export {
    return Math::Matrix.new-identity( $a!row-count ) if $e ==  0;
    my $p = $a.clone;
    $p = $p.dotProduct( $a ) for 2 .. abs $e;
    $p = $p.inverted         if  $e < 0;
    $p;
}

multi sub circumfix:<| |>(Math::Matrix $a --> Numeric) is equiv(&prefix:<!>) is export {
    $a.determinant();
}

multi sub circumfix:<|| ||>(Math::Matrix $a --> Numeric) is equiv(&prefix:<!>) is export {
    $a.norm();
}
