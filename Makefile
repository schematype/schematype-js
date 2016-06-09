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

NAME := $(shell grep '^name: ' Meta 2>/dev/null | cut -d' ' -f2)
VERSION := $(shell grep '^version: ' Meta 2>/dev/null | cut -d' ' -f2)
DISTDIR := $(NAME)-$(VERSION)
DIST := $(DISTDIR).tgz

ALL_LIB_DIR := $(shell find lib -type d)
ALL_NPM_DIR := $(ALL_LIB_DIR:%=npm/%)
ALL_COFFEE := $(shell find lib -name *.coffee)
ALL_NPM_JS := $(ALL_COFFEE:%.coffee=npm/%.js)

.PHONY: npm doc test

default: help

help:
	echo "$$HELP"

testXXX:
	coffee -e '(require "./test/lib/test/harness").run()' $@/*.coffee

test:
	./test/test.coffee

install: npm
	(cd npm; npm install -g .)
	rm -fr npm

doc:
	swim --to=pod --complete --wrap doc/$(NAME).swim > ReadMe.pod

npm:
	./.pkg/bin/make-npm

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
	git tag $(VERSION)
	git push --tag
	rm $(DIST)

publish-dryrun: check-release dist
	echo npm publish $(DIST)
	echo git tag $(VERSION)
	echo git push --tag
	rm $(DIST)

clean purge:
	rm -fr npm node_modules $(DIST) $(DISTDIR)

upgrade:
	(PKGREPO=$(PWD) make -C ../javascript-pkg do-upgrade)

#------------------------------------------------------------------------------
check-release:
	./.pkg/bin/check-release

do-upgrade:
	mkdir -p $(PKGREPO)/.pkg/bin
	cp Makefile $(PKGREPO)/Makefile
	cp -r bin/* $(PKGREPO)/.pkg/bin/
