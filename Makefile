COFFEE = $(shell find src -name "*.coffee")
JS = $(COFFEE:src%.coffee=lib%.js)

all: $(JS)

lib/%.js : src/%.coffee
	./node_modules/.bin/coffee \
		--compile \
		--output lib $<

clean:
	rm -rf lib/*

test : test-support

test-support :
	./node_modules/.bin/mocha test/support_test --ui qunit --bail --colors

# ---

# Only useful if you use dropbox to keep this folder in sync between two
# machines
fix-symlinks :
	cd node_modules/.bin && rm -rf * && ln -s ../*/bin/* .

.PHONY: test tag fix-symlinks
