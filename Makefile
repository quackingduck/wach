lib-js:
	./node_modules/.bin/coffee --compile --lint --output lib src

watchdir:
	clang -Wall -framework CoreServices -o bin/wach-watchdir src/watchdir.c

test:
	./node_modules/.bin/mocha --ui tdd

.PHONY: test
