use v6.c;

unit role Math::Matrix::Operators;

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
