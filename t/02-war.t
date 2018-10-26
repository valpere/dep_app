#!/usr/bin/env perl
package t_02_war;

use strict;
use warnings 'all';

use Test::More tests => 12;
use Test::MockModule;

use lib qw(../lib);

use Wono::Logger qw(init_logger);

my $params = {
    application => '/home/val/wrk/test/hello-war.war',
    data_dir    => '.',
    drivers     => {
        tomcat8 => {
            password => '',
            proxy    => '',
            username => ''
        }
    },
    logger => {
        'log4perl.logger'                                   => 'TRACE, SCREEN',
        'log4perl.appender.SCREEN'                          => 'Log::Log4perl::Appender::ScreenColoredLevels',
        'log4perl.appender.SCREEN.layout'                   => 'PatternLayout',
        'log4perl.appender.SCREEN.stderr'                   => '1',
        'log4perl.appender.SCREEN.layout.ConversionPattern' => '%d{ISO8601} [%P]: <%p> %M:%L - %m%n',
        'log4perl.appender.SCREEN.Threshold'                => 'OFF',
    },
    path            => '/hello-war',
    target_config   => './test.conf',
    update          => 0,
    verbose_verbose => 0
};

use Wono::DepApp;

init_logger( $params->{logger} );

my $wono_mock = Test::MockModule->new('Wono');

$wono_mock->mock( 'initialize', sub { } );
$wono_mock->mock( 'params',     sub {$params} );

my $tomcat8_mock = Test::MockModule->new('Wono::Driver::Tomcat8');

my $dep_app = Wono::DepApp->new;

my $ok;

my $existing_ok = q{OK - Listed applications for virtual host localhost
/:running:0:ROOT
/hello-war:running:0:hello-war
/host-manager:running:0:host-manager
/manager:running:1:manager};
$tomcat8_mock->mock( 'call', sub {$existing_ok} );
$ok = $dep_app->action_existing;
ok( $ok, 'call action_existing: ok' );

my $existing_no = q{OK - Listed applications for virtual host localhost
/:running:0:ROOT
/host-manager:running:0:host-manager
/manager:running:1:manager};
$tomcat8_mock->mock( 'call', sub {$existing_no} );
$ok = !$dep_app->action_existing;
ok( $ok, 'call action_existing: no' );

my $deploy_ok = q{OK - Deployed application at context path /hello-war};
$tomcat8_mock->mock( 'call', sub {$deploy_ok} );
$ok = $dep_app->action_deploy;
ok( $ok, 'call action_deploy: ok' );

my $deploy_no = q{FAIL - Application already exists at path /hello-war};
$tomcat8_mock->mock( 'call', sub {$deploy_no} );
$ok = !$dep_app->action_deploy;
ok( $ok, 'call action_deploy: no' );

my $stop_ok = q{OK - Stopped application at context path /hello-war};
$tomcat8_mock->mock( 'call', sub {$stop_ok} );
$ok = $dep_app->action_stop;
ok( $ok, 'call action_stop: ok' );

my $stop_no = q{FAIL - No context exists named /hello-war};
$tomcat8_mock->mock( 'call', sub {$stop_no} );
$ok = !$dep_app->action_stop;
ok( $ok, 'call action_stop: no' );

my $start_ok = q{OK - Started application at context path /hello-war};
$tomcat8_mock->mock( 'call', sub {$start_ok} );
$ok = $dep_app->action_start;
ok( $ok, 'call action_start: ok' );

my $start_no = q{FAIL - No context exists named /hello-war};
$tomcat8_mock->mock( 'call', sub {$start_no} );
$ok = !$dep_app->action_start;
ok( $ok, 'call action_start: no' );

my $undeploy_ok = q{OK - Undeployed application at context path /hello-war};
$tomcat8_mock->mock( 'call', sub {$undeploy_ok} );
$ok = $dep_app->action_undeploy;
ok( $ok, 'call action_undeploy: ok' );

my $undeploy_no = q{FAIL - No context exists named /hello-war};
$tomcat8_mock->mock( 'call', sub {$undeploy_no} );
$ok = !$dep_app->action_undeploy;
ok( $ok, 'call action_undeploy: no' );

my $available_ok = q{};
$tomcat8_mock->mock( 'call', sub {$available_ok} );
$ok = $dep_app->action_available;
ok( $ok, 'call action_available: ok' );

my $available_no = qq{ERROR: Exception: 404, Description: 404 Not Found\n};
$tomcat8_mock->mock( 'call', sub { die($available_no) } );
$ok = !$dep_app->action_available;
ok( $ok, 'call action_available: no' );

#*****************************************************************************
1;
__END__
