COFFEE = $(shell find src -name "*.coffee")
JS = $(COFFEE:src%.coffee=lib%.js)

all: bin/wach-watchdir $(JS)

lib/%.js : src/%.coffee
	./node_modules/.bin/coffee \
		--compile \
		--lint \
		--output lib $<

clean:
	rm -rf lib/*

test : test-support

test-support :
	./node_modules/.bin/mocha test/support_test --ui qunit --bail --colors

tag:
	git tag v`coffee -e "console.log JSON.parse(require('fs').readFileSync 'package.json').version"`

# ---

# Only useful if you use dropbox to keep this folder in sync between two
# machines
fix-symlinks :
	cd node_modules/.bin && rm -rf * && ln -s ../*/bin/* .

.PHONY: test tag fix-symlinks
