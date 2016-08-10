define HELP

Makefile targets:

    make test     - Run the repo tests
    make install  - Install the repo
    make doc      - Make the docs

    make npm      - Make npm/ dir for Node
    make dist     - Make NPM distribution tarball
    make distdir  - Make NPM distribution directory
    make disttest - Run the dist tests
    make publish  - Publish the dist to NPM
    make publish-dryrun   - Don'"'"'t actually push to NPM

    make upgrade  - Upgrade the build system
    make clean    - Clean up build files

endef
export HELP
export NODE_PATH=$(shell npm config get prefix)/lib/node_modules

NAME := $(shell grep '^name: ' Meta 2>/dev/null | cut -d' ' -f2)
VERSION := $(shell grep '^version: ' Meta 2>/dev/null | cut -d' ' -f2)
DISTDIR := $(NAME)-$(VERSION)
DIST := $(DISTDIR).tgz
DOCKER_IMAGE := schematype/stp

ALL_LIB_DIR := $(shell find lib -type d)
ALL_NPM_DIR := $(ALL_LIB_DIR:%=npm/%)
ALL_COFFEE := $(shell find lib -name *.coffee)
ALL_NPM_JS := $(ALL_COFFEE:%.coffee=npm/%.js)

MAN = $(MAN1)/$(NAME).1
MAN1 = man/man1

.PHONY: npm doc test

default: help

help:
	echo "$$HELP"

update: doc

doc: $(MAN) ReadMe.pod

$(MAN1)/%.1: doc/%.swim
	swim --to=man $< > $@

testXXX:
	coffee -e '(require "./test/lib/test/harness").run()' $@/*.coffee

test: ext/test-more-bash node_modules
	@prove -lv test/

ext/test-more-bash:
	git clone git@github.com:ingydotnet/test-more-bash $@

install: npm
	(cd npm; npm install -g .)
	rm -fr npm

ReadMe.pod: doc/$(NAME).swim
	swim --to=pod --complete --wrap $< > $@

npm:
	./.pkg/bin/make-npm

node: node_modules
node_modules:
	./.pkg/bin/make-package-json > package.json
	npm install .
	rm package.json

dist: clean npm
	npm pack ./npm/
	rm -fr npm

distdir: clean dist
	tar xzf $(DIST)
	rm -fr npm $(DIST)
	mv package $(DISTDIR)

disttest: distdir
	(cd $(DISTDIR); npm test) && rm -fr npm

publish: doc check-release dist
	npm publish $(DIST)
	git push
	git tag $(VERSION)
	git push --tag
	rm $(DIST)

publish-dryrun: check-release dist
	echo npm publish $(DIST)
	echo git tag $(VERSION)
	echo git push --tag
	rm $(DIST)

clean purge:
	rm -fr ext npm node_modules tmp $(DIST) $(DISTDIR)

upgrade:
	(PKGREPO=$(PWD) make -C ../javascript-pkg do-upgrade)

#------------------------------------------------------------------------------
check-release:
	./.pkg/bin/check-release

do-upgrade:
	mkdir -p $(PKGREPO)/.pkg/bin
	cp Makefile $(PKGREPO)/Makefile
	cp -r bin/* $(PKGREPO)/.pkg/bin/

#------------------------------------------------------------------------------
docker-build: npm
	docker build -t $(DOCKER_IMAGE) .

docker-push:
	docker push $(DOCKER_IMAGE)

docker-shell:
	docker run -it --entrypoint=/bin/bash $(DOCKER_IMAGE)
