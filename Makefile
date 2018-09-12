ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# default command requires a running minishift cluster
build: guard-image
	docker build -t $(image) .

build-nocache: guard-image
	docker build --no-cache -t $(image) .

push: guard-image
	docker push $(image)

# If a client is not supplied to some scripts we wanna stop right there
# This is a bit weird but does the trick
# I'll find a better solutio\n at some point
guard-image:
	@echo "Using image: $${image:?}"
