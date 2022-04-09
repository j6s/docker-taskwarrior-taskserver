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
    if [ ! -z ${CERT_CN+x} ]; then
        sed -i "s\CN=.*\CN=${CERT_CN}\g" vars
    else
        echo "===> No CN defined. This will only work if the taskserver client runs on the same machine"
    fi
    if [ ! -z ${CERT_KEY_LENGTH} ]; then
        sed -i "s\BITS=.*\BITS=${CERT_KEY_LENGTH}\g" vars
    fi
    if [ ! -z ${CERT_EXPIRATION_DAYS+x} ]; then
        sed -i "s\EXPIRATION_DAYS=.*\EXPIRATION_DAYS=${CERT_EXPIRATION_DAYS}\g" vars
    fi
    if [ ! -z ${CERT_ORGANIZATION+x} ]; then
        sed -i "s\ORGANIZATION=.*\ORGANIZATION=${CERT_ORGANIZATION}\g" vars
    fi
    if [ ! -z ${CERT_COUNTRY+x} ]; then
        sed -i "s\COUNTRY=.*\COUNTRY=${CERT_COUNTRY}\g" vars
    fi
    if [ ! -z ${CERT_STATE+x} ]; then
        sed -i "s\STATE=.*\STATE=${CERT_STATE}\g" vars
    fi
    if [ ! -z ${CERT_LOCALITY+x} ]; then
        sed -i "s\LOCALITY=.*\LOCALITY=${CERT_LOCALITY}\g" vars
    fi

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
    if [ -z ${ORGANIZATION+x} ]; then
        ORGANIZATION=Default
    fi
    if [ -z ${USER+x} ]; then
        USER=Default
    fi
    echo "===> No users setup yet. Setting up organization ${ORGANIZATION}  with user ${USER}"
    execute taskd add org ${ORGANIZATION}
    execute taskd add user ${ORGANIZATION} ${USER}
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
echo "  $ task config taskd.cat         -- ~/.task/cat.cert.pem"
echo "  $ task config taskd.server      -- ${CERT_CN}:53589"
echo "  $ task config taskd.credentials -- ${ORGANIZATION}/${USER}/$(ls $TASKDDATA/orgs/${ORGANIZATION}/users)"

echo ""
echo ""


execute taskd server --data $TASKDDATA
