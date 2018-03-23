use v6.c;

unit role Math::Matrix::Operators;

multi sub infix:<+>(::?CLASS $a, ::?CLASS $b --> ::?CLASS:D ) is export {
    $a.add($b);
}

multi sub infix:<+>(::?CLASS $a, Real $r --> ::?CLASS:D ) is export {
    $a.add( $r );
}
multi sub infix:<+>(Real $r, ::?CLASS $a --> ::?CLASS:D ) is export {
    $a.add( $r );
}

multi sub infix:<->(::?CLASS $a, ::?CLASS $b --> ::?CLASS:D ) is export {
    $a.subtract($b);
}
multi sub infix:<->(::?CLASS $a, Real $r --> ::?CLASS:D ) is export {
    $a.add( -$r );
}
multi sub infix:<->(Numeric $r, ::?CLASS $a --> ::?CLASS:D ) is export {
    $a.negated.add( $r );
}

multi sub prefix:<->(::?CLASS $a --> ::?CLASS:D ) is export {
    $a.negated();
}

multi sub infix:<⊗>( ::?CLASS $a, ::?CLASS $b  --> ::?CLASS:D ) is looser(&infix:<*>) is export {
    $a.tensorProduct( $b );
}

multi sub infix:<x>( ::?CLASS $a, ::?CLASS $b  --> ::?CLASS:D ) is looser(&infix:<*>) is export {
    $a.tensorProduct( $b );
}

multi sub infix:<⋅>( ::?CLASS $a, ::?CLASS $b --> ::?CLASS:D ) is looser(&infix:<*>) is export {
    $a.dotProduct( $b );
}

multi sub infix:<dot>(::?CLASS $a, ::?CLASS $b --> ::?CLASS:D ) is looser(&infix:<*>) is export {
    $a.dotProduct( $b );
}

multi sub infix:<*>(::?CLASS $a, Real $r --> ::?CLASS:D ) is export {
    $a.multiply( $r );
}

multi sub infix:<*>(Numeric $r, ::?CLASS $a --> ::?CLASS:D ) is export {
    $a.multiply( $r );
}

multi sub infix:<*>(::?CLASS $a, ::?CLASS $b  --> ::?CLASS:D ) is export {
    $a.multiply( $b );
}

multi sub infix:<**>(::?CLASS $a where { $a.is-square }, Int $e --> ::?CLASS:D ) is export {
    return Math::Matrix.new-identity( $a!row-count ) if $e ==  0;
    my $p = $a.clone;
    $p = $p.dotProduct( $a ) for 2 .. abs $e;
    $p = $p.inverted         if  $e < 0;
    $p;
}

multi sub circumfix:<| |>(::?CLASS $a --> Numeric) is equiv(&prefix:<!>) is export {
    $a.determinant();
}

multi sub circumfix:<|| ||>(::?CLASS $a --> Numeric) is equiv(&prefix:<!>) is export {
    $a.norm();
}
