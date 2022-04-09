# Taskwarrior taskserver

Docker container containing the taskserver for taskwarrior.
This container sets up a complete single-user environment without any
intervention.

## Usage

```bash
$ docker run \
    --rm -it \
    -v $(pwd)/data:/data \
    -p 53589:53589 \
    j6s/taskwarrior-taskserver
```

On first run this will
- Create self signed certificates for the server
- Create an organization called 'Default'
- Create a user called 'Default' in that organization
- Create client certificates for that user
- Print information on how to configure clients to use this server

On subsequent runs only the last part will be done.

## Configuration
The following Enviroment Variables are supported
CERT_CN: This sets the CN for the Certificate. This is probably the most important variable, because it is checked by taskwarrior by default.
CERT_KEY-LENGTH: The Bit Length of the certificate
CERT_EXPIRATION_DAYS: The days after which the Certificate expires
CERT_ORGANIZATION: The owner Organization of the certificate
CERT_COUNTRY: The Country for the certificate
CERT_STATE: The State in the country for the Certificate
CERT_LOCALITY: The Locality for the Certificate
ORGANIZATION: The generated Organization in Taskd
USER: The generated user in Taskd
