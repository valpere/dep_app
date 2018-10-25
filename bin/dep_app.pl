#!/usr/bin/env perl
package dep_app;

use utf8;
use strict;
use warnings FATAL => 'all';

use Const::Fast;

# search for libs in script's directory
use FindBin qw($Bin);
use lib("$Bin/../site_lib");

use Wono::DepApp;

#*****************************************************************************
const my $_OPTS => [
    'action|ac=s@',
    'application|ap=s',
    'target_config|tc=s',
];

#*****************************************************************************

Wono::DepApp->new->run( {}, $_OPTS );

#*****************************************************************************
1;
__END__

=head1 NAME

dep_app.pl -- deploy/undeploy WAR-applications

* Saving/deleting of the configuration
* Deploy/undeploy of an application
* Start/Stop of the application
* Check deployed application

=head1 SYNOPSIS

    dep_app.pl \
        [-(help|h|?)] \
        [-man] \
        [-(verbose|v)] \
        [-(verbose_verbose|vv)] \
        [-(config|c)=</path/to/configfile>] \
        [-(data_dir|d)=</path/to/data_dir>] \

    Where:
        -help                  - brief help message
        -man                   - full documentation
        -verbose               - verbose mode
        -verbose_verbose       - more verbose mode
        -config                - path to config file
        -data_dir              - output directory

    NOTE:
        Log file is dep_app.log is located in output directory.

=head1 OPTIONS

=head2 -help

Print a brief help message and exits.

=head2 -man

Prints the manual page and exits.

=head3 -verbose

Prints more debug information into log file

=head3 -verbose_verbose

Prints even more debug information into log file

=head2 -config

Path to configuration file.

Default is dep_app.conf in script's directory

=head2 -data_dir

Working directory.

Default is current dir.

=cut
