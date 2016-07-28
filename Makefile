DOCKER_IMAGE_TAG := ingy/stp-validate-cf-manifest
DOCKER_RUN_COMMAND := \
    docker run -it \
    --entrypoint=bash \
    -v $$PWD:/data \
    $(DOCKER_IMAGE_TAG)

build: stp/manifest.jsc
	docker build -t $(DOCKER_IMAGE_TAG) .

push: build
	docker push $(DOCKER_IMAGE_TAG)

shell: build
	$(DOCKER_RUN_COMMAND)

stp/manifest.jsc: stp/manifest.jsc.yaml Makefile
	jyj $< \
	    | jq 'del(.const,.definitions.shared)' \
	    | jq 'del(.definitions) + {definitions: .definitions}' \
	    > $@
