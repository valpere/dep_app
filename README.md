# dep_app
Deploy/undeploy WAR-application

Saving/deleting of the configuration
Deploy/undeploy of an application
Start/Stop of the application
Check deployed application

For application server:
Tomcat

And a set of tests (simple unit tests, e.g. check command line)
We are not going to test exact work of this module, we just want to see code/architecture.

Configuration can be saved somewhere (sqlite, text file, etc).
Encryption is not needed, so passwords can be stored as plaintext for the sake of simplicity.
The module should support multiple configurations.

Deploy/undeploy - let’s assume we’ve got a simple application somewhere on the disk (so we have the path).
We want it to be deployed on the application server.

In general, module should implement the following pipeline:
* Deploy application
* Start application
* Check if application works and responses
* Undeploy application
* Check if application no longer available

Also, command line utility for this module should be created.

Requirements for command line utility are:
It should be configurable through config file (--config file) option
Options could be passed through command line arguments, if config file is not present. For example: --hostname --user --password.
For example, syntax of command line utility could be:
./tool --config config.txt --action deploy --application hello-world.war

#-----------------------------------------------------------------------------
Lives here:
https://github.com/valpere/dep_app

Requires it:
https://github.com/valpere/wono
#-----------------------------------------------------------------------------
Tested on Fedora Core 27
tomcat-8.0.51-1.fc27.noarch

Example:

work_dir=000-dep_app

export PERL5LIB="../lib:$PERL5LIB"

../bin/dep_app.pl \
    -data_dir=$work_dir \
    -config=dep_app.conf \
    -path=/hello-war \
    -update \
    -application=/home/val/wrk/test/hello-war.war \
    -action=deploy \
    -action=existing \
    -action=stop \
    -action=existing \
    -action=start \
    -action=available \
    -action=undeploy \
    -action=existing \
