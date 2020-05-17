#!/bin/bash

function execute {
    echo "$ $@"
    eval $@
}

if [ ! -w $TASKDDATA ]; then
    echo "$TASKDDATA is not writable for user. Please ensure that it belongs to user id 1000"
    exit 255;
fi;

if [ ! -d $TASKDDATA/pki ]; then
    execute cp -R /pki $TASKDDATA/pki
fi;

if [ ! -f $TASKDDATA/config ]; then
    echo "===> $TASKDDATA/config not found. Initializing taskd."
    execute taskd init
    execute taskd config --force log $TASKDDATA/taskd.log
    execute taskd config --force pid.file /taskd.pid
    execute taskd config --force server 0.0.0.0:53589
fi;


if [ ! -f $TASKDDATA/pki/ca.cert.pem ]; then
    echo '===> No certificates found. Initializing self-signed ones.'
    cd $TASKDDATA/pki
    execute ./generate

    execute taskd config --force client.cert $TASKDDATA/pki/client.cert.pem
    execute taskd config --force client.key  $TASKDDATA/pki/client.key.pem
    execute taskd config --force server.cert $TASKDDATA/pki/server.cert.pem
    execute taskd config --force server.key  $TASKDDATA/pki/server.key.pem
    execute taskd config --force server.crl  $TASKDDATA/pki/server.crl.pem
    execute taskd config --force ca.cert     $TASKDDATA/pki/ca.cert.pem
else
    echo '===> Certificates already exist'
fi;

if [ ! -f $TASKDDATA/pki/default-client.key.pem ]; then
    echo '===> No users setup yet. Setting up organization Default with user Default'
    execute taskd add org Default
    execute taskd add user Default Default
    cd $TASKDDATA/pki
    ./generate.client default-client
fi;

echo ""
echo ""
echo "You are all set to use taskd."
echo "Execute the following steps to setup your client:"
echo "1. Get the keys data/pki/default-client.{key,cert}.pem"
echo "   & ca.cert.pem and place them in ~/.task/"
echo "2. Execute on your client:"
echo "  $ task config taskd.certificate -- ~/.task/default-client.cert.pem"
echo "  $ task config taskd.key         -- ~/.task/default-client.key.pem"
echo "  $ task config taskd.ca          -- ~/.task/ca.cert.pem"
echo "  $ task config taskd.server      -- host.domain:53589"
echo "  $ task config taskd.credentials -- Default/Default/$(ls $TASKDDATA/orgs/Default/users)"
echo "3*. If you are setting up on a remote machine you might need to ommit hostname validataion:"
echo "  $ task config taskd.trust ignore hostname"
echo ""
echo ""


execute taskd server --data $TASKDDATA
