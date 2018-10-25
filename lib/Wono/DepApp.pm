package Wono::DepApp;

use utf8;

our $VERSION = 0.010;

use Mouse;

extends 'Wono';

use Const::Fast;
use English qw( -no_match_vars );
use File::Spec ();
use Ref::Util qw(
    is_arrayref
    is_hashref
);
use IO::File ();
use List::MoreUtils qw(uniq);
use Clone qw(clone);

# search for libs in module's directory
use FindBin qw($Bin);
use lib($Bin);

use Wono::Utils qw(
    :json
);
use Wono::Driver::Tomcat8;
use Wono::Logger qw(
    init_logger
    logger
    debugd
    info
    infof
    fatalf
);

#*****************************************************************************
const my $_KNOWN_ACTIONS => {
    deploy        => 1,
    undeploy      => 1,
    start         => 1,
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

has 'json' => (
    is      => 'ro',
    isa     => 'Object',
    builder => 'json_obj',
);

#*****************************************************************************
sub initialize {
    my ( $self, $preps, $opts ) = @_;

    $self->SUPER::initialize( $preps, $opts );

    my $actions = [ uniq @{ $self->params->{action} || [] } ];
    if ( @{$actions} < 1 ) {
        fatalf( 'Please specify one of the actions: %s', join( ', ', sort keys %{$_KNOWN_ACTIONS} ) );
    }

    $self->params->{action} = $actions;

    return undef;
}

#*****************************************************************************
sub finalize {
    my ( $self, $msg ) = @_;

    $self->SUPER::finalize($msg);

    return undef;
}

#*****************************************************************************
sub process_init {
    my ($self) = @_;

    return 1;
}

#*****************************************************************************
sub process_done {
    my ($self) = @_;

    return 1;
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

    infof( 'Iteration begin: %s', $action );
    $self->$handler();
    infof( 'Iteration end: %s', $action );

    return scalar( @{ $self->params->{action} } );
}

#*****************************************************************************
sub action_deploy {
    my ($self) = @_;

    return undef;
}

#*****************************************************************************
sub action_undeploy {
    my ($self) = @_;

    return undef;
}

#*****************************************************************************
sub action_start {
    my ($self) = @_;

    return undef;
}

#*****************************************************************************
sub action_available {
    my ($self) = @_;

    return undef;
}

#*****************************************************************************
sub action_existing {
    my ($self) = @_;

    return undef;
}

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

    return undef;
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

    return undef;
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
