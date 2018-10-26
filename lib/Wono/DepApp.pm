package Wono::DepApp;

use utf8;

our $VERSION = 0.010;

use Mouse;

extends 'Wono';

use Const::Fast;
use English qw( -no_match_vars );
use List::MoreUtils qw(
    first_value
);
use Clone qw(clone);
use File::Basename qw(fileparse);

# search for libs in module's directory
use FindBin qw($Bin);
use lib($Bin);

use Wono::Utils qw(
    :json
    strip_spaces
);
use Wono::Driver::Tomcat8;
use Wono::Logger qw(
    debugf
    debugd
    infof
    errorf
    fatalf
    warningf
);

#*****************************************************************************
const my $_KNOWN_ACTIONS => {
    deploy        => 1,
    undeploy      => 1,
    start         => 1,
    stop          => 1,
    available     => 1,
    existing      => 1,
    save_config   => 1,
    delete_config => 1,
};

#*****************************************************************************
has 'driver' => (
    is       => 'ro',
    isa      => 'Wono::Driver',
    lazy     => 1,
    builder  => '_init_driver',
    init_arg => undef,
);

#*****************************************************************************
sub initialize {
    my ( $self, $preps, $opts ) = @_;

    $self->SUPER::initialize( $preps, $opts );

    if ( @{ $self->params->{action} || [] } < 1 ) {
        fatalf( 'Please specify one of the actions: %s', join( ', ', sort keys %{$_KNOWN_ACTIONS} ) );
    }

    return undef;
}

#*****************************************************************************
sub process_iteration {
    my ($self) = @_;

    my $action = shift( @{ $self->params->{action} } );
    if ( !exists( $_KNOWN_ACTIONS->{$action} ) ) {
        fatalf( 'Unknown action: %s', $action );
    }

    my $handler = sprintf( 'action_%s', $action );
    if ( !$self->can($handler) ) {
        fatalf( q{Cannot handle action '%s'}, $action );
    }

    debugf( 'Iteration begin: %s', $action );
    $self->$handler();
    debugf( 'Iteration end: %s', $action );

    return scalar( @{ $self->params->{action} } );
}

#*****************************************************************************
sub action_deploy {
    my ($self) = @_;

    my $params = {
        path => $self->params->{path},
    };

    if ( $self->params->{path} ) {
        $params->{update} = 'true';
    }

    my $resp = $self->driver->call( {
            method      => 'PUT',
            action      => '/manager/text/deploy',
            params      => $params,
            attachments => $self->params->{application},
        }
    );

    if ( $resp =~ m/^OK\s+/ ) {
        infof($resp);
    }
    else {
        warningf($resp);
        return 0;
    }

    return 1;
} ## end sub action_deploy

#*****************************************************************************
sub action_undeploy {
    my ($self) = @_;

    my $params = {
        path => $self->params->{path},
    };

    my $resp = $self->driver->call( {
            method => 'GET',
            action => '/manager/text/undeploy',
            params => $params,
        }
    );

    if ( $resp =~ m/^OK\s+/ ) {
        infof($resp);
    }
    else {
        warningf($resp);
        return 0;
    }

    return 1;
} ## end sub action_undeploy

#*****************************************************************************
sub action_start {
    my ($self) = @_;

    my $params = {
        path => $self->params->{path},
    };

    my $resp = $self->driver->call( {
            method => 'GET',
            action => '/manager/text/start',
            params => $params,
        }
    );

    if ( $resp =~ m/^OK\s+/ ) {
        infof($resp);
    }
    else {
        warningf($resp);
        return 0;
    }

    return 1;
} ## end sub action_start

#*****************************************************************************
sub action_stop {
    my ($self) = @_;

    my $params = {
        path => $self->params->{path},
    };

    my $resp = $self->driver->call( {
            method => 'GET',
            action => '/manager/text/stop',
            params => $params,
        }
    );

    if ( $resp =~ m/^OK\s+/ ) {
        infof($resp);
    }
    else {
        warningf($resp);
        return 0;
    }

    return 1;
} ## end sub action_stop

#*****************************************************************************
sub action_available {
    my ($self) = @_;

    local $EVAL_ERROR = undef;

    my $resp = eval {
        $self->driver->call( {
                method => 'HEAD',
                action => $self->params->{path},
            }
        );
    };

    if ( my $eval_error = $EVAL_ERROR ) {
        errorf( strip_spaces($eval_error) );
        return 0;
    }

    infof( q{Application at '%s' is available}, $self->params->{path} );

    return 1;
} ## end sub action_available

#*****************************************************************************
sub action_existing {
    my ($self) = @_;

    my $resp = $self->driver->call( {
            method => 'GET',
            action => '/manager/text/list',
        }
    );

    my @list = split( m/\r?\n/, $resp );

    infof( shift(@list) );

    my $path = $self->params->{path};
    my ($name) = fileparse( $self->params->{application} );

    $name =~ s/\.war$//i;

    my $regexp = qr/^$path:.+?:$name$/;

    my $our_app = first_value { $_ =~ $regexp } @list;

    if ( !$our_app ) {
        warningf( q{Application '%s' doesn't exist}, $name );
        return 0;
    }

    my ( undef, $running ) = split( ':', $our_app, 3 );
    infof( q{Application '%s' exists and %s}, $name, $running );

    return 1;
} ## end sub action_existing

#*****************************************************************************
sub action_save_config {
    my ($self) = @_;

    my $target_config = $self->params->{target_config};
    if ( ( $target_config // '' ) eq '' ) {
        fatalf('Unspecified target config for save_config');
    }

    my $data = clone( $self->params );

    delete( @{$data}{qw(action config target_config)} );

    infof( q{Save config to '%s'}, $target_config );
    json_save( $target_config, $data );

    return 1;
}

#*****************************************************************************
sub action_delete_config {
    my ($self) = @_;

    my $target_config = $self->params->{target_config};
    if ( ( $target_config // '' ) eq '' ) {
        fatalf('Unspecified target config for delete_config');
    }

    infof( q{Delete config '%s'}, $target_config );
    unlink($target_config);

    return 1;
}

#*****************************************************************************
sub _init_driver {
    my ($self) = @_;

    return Wono::Driver::Tomcat8->new( {
            %{ $self->params->{drivers}->{tomcat8} },
            verbose         => $self->verbose,
            verbose_verbose => $self->verbose_verbose,
        }
    );
}

#*****************************************************************************
no Mouse;
__PACKAGE__->meta->make_immutable;
#*****************************************************************************
1;
__END__
