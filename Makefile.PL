# Original authors: don
# $Revision$

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
              NAME => 'Pod::POM::View::Restructured',
              DISTNAME => 'Pod-POM-View-Restructured',
              VERSION_FROM => 'lib/Pod/POM/View/Restructured.pm',
              ABSTRACT_FROM => 'lib/Pod/POM/View/Restructured.pm',
              # AUTHOR => '',
              PM => {
                     'lib/Pod/POM/View/Restructured.pm' => '$(INST_LIBDIR)/Restructured.pm',
                     'lib/Pod/POM/View/Restructured/Changes.pm' => '$(INST_LIBDIR)/Restructured/Changes.pm',
                    },
              dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
              # DIR => [ ],
              EXE_FILES => [ 'bin/pod2rst' ],
              PREREQ_PM => { 'Pod::POM' => 0 },
              clean => { FILES => 'Pod-POM-View-Restructured-*.tar.gz' },
);

