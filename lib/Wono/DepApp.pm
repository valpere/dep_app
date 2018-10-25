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

# search for libs in module's directory
use FindBin qw($Bin);
use lib($Bin);

use Wono::Utils qw(
    :json
);
use Wono::Driver::Tomcat8;

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

    # $self->SUPER::initialize( $preps, $opts );

    return undef;
}

#*****************************************************************************
sub finalize {
    my ( $self, $msg ) = @_;

    # $self->SUPER::finalize($msg);

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

    return 0;
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
