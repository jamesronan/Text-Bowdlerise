#!perl -T

use lib '../lib';
use Test::More;

BEGIN {
    use_ok( 'Text::Bowdlerise' );
}

my @tests = (
    {
        name   => 'Fuck',
        text   => "Don't be silly and fuck up the config!",
        expect => "Don't be silly and ruin up the config!",
    },
    {
        name   => 'Fuck-up',
        text   => 'Complete fuck-up that was!',
        expect => 'Complete ruin-up that was!',
    },
    {
        name   => 'Twat',
        text   => 'Because $otherdev is a Twat...',
        expect => 'Because $otherdev is a ladypart...',
    },
    {
        name   => 'Shit',
        text   => '... do it in a less shit way ...',
        expect => '... do it in a less faeces way ...',
    },
    {
        name   => 'Motherfucker',
        text   => 'As Samual L Jackson said: "stupid motherfucker"',
        expect => 'As Samual L Jackson said: "stupid mater-lover"',
    },    
    {
        name   => 'Boobs',
        text   => 'I like tits',
        expect => 'I like breasts',
    },
);
plan tests => scalar @tests;

for my $test (@tests) {
    is(Text::Bowdlerise->new($test->{text}), $test->{expect}, $test->{name});
}

