use 5.008;
use ExtUtils::MakeMaker;

my @bins = qw(dep_app.pl);

WriteMakefile(
    'NAME'         => 'DepApp',
    'DISTNAME'     => 'DepApp',
    'VERSION_FROM' => 'lib/Wono/DepApp.pm',
    'ABSTRACT'     => 'Deploy/undeploy WAR-applications.',
    'LICENSE'      => 'GPLv3',
    #   'ABSTRACT_FROM' => 'lib/Wono.pm',
    'EXE_FILES' => [ map "bin/$_", @bins ],
    'AUTHOR'    => 'Valentyn Solomko <Valentyn.Solomko@gmail.com>',
    'PREREQ_PM' => {
        'Const::Fast'           => 0,
        'English'               => 0,
        'File::Spec'            => 0,
        'FindBin'               => 0,
        'IO::File'              => 0,
        'Mouse'                 => 0,
        'Ref::Util'             => 0,
        'Wono::Driver::Tomcat8' => 0,
        'Wono::Utils'           => 0,
    },
    'dist' => {
        COMPRESS => 'gzip -9f',
        SUFFIX   => 'gz',
    },
    'clean' => { FILES => 'DepApp-*' },
);
