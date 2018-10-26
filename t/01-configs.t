#!/usr/bin/env perl
package t_01_configs;

use strict;
use warnings 'all';

use Test::More tests => 4;
use Test::MockModule;

use lib qw(../lib);

use Wono::Logger qw(init_logger);

my $params = {
    application => '/home/val/wrk/test/hello-war.war',
    data_dir    => '.',
    drivers     => {
        tomcat8 => {
            password => 'secret',
            proxy    => 'http://localhost:8080',
            username => 'admin'
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
    update          => 1,
    verbose_verbose => 1
};

use Wono::DepApp;

init_logger( $params->{logger} );

my $wono_mock = Test::MockModule->new('Wono');

$wono_mock->mock( 'initialize', sub { } );
$wono_mock->mock( 'params',     sub {$params} );

my $dep_app = Wono::DepApp->new;

my $ok;

$ok = $dep_app->action_save_config;
ok( $ok, 'call action_save_config' );

$ok = ( -e $params->{target_config} );
ok( $ok, 'saved config exists' );

$ok = $dep_app->action_delete_config;
ok( $ok, 'call action_delete_config' );

$ok = ( !-e $params->{target_config} );
ok( $ok, 'saved was deleted' );

#*****************************************************************************
1;
