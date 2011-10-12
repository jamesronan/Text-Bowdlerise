#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Text::Bowdlerise' ) || print "Bail out!
";
}

diag( "Testing Text::Bowdlerise $Text::Bowdlerise::VERSION, Perl $], $^X" );
