
image:
	docker build -t 'j6s/taskwarrior-taskserver' -f ./docker/taskserver.Dockerfile ./docker

run: image
	docker run --rm -it -v $(shell pwd)/data:/data -p 53589:53589 j6s/taskwarrior-taskserver