use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Text::Bowdlerise',
    AUTHOR              => q{James Ronan <james@ronanweb.co.uk>},
    VERSION_FROM        => 'lib/Text/Bowdlerise.pm',
    ABSTRACT_FROM       => 'lib/Text/Bowdlerise.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'gpl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Text-Bowdlerise-*' },
);
