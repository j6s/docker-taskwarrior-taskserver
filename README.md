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

## Troubleshooting
Address [official documentation](https://taskwarrior.org/docs/taskserver/setup.html) to make sure you have set all the parameters correctly.
