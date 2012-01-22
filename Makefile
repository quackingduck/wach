lib-js:
	./node_modules/.bin/coffee --compile --lint --output lib src

watchdir:
	clang -Wall -framework CoreServices -o bin/wach-watchdir src/watchdir.c

test:
	./node_modules/.bin/mocha --ui tdd

tag:
	git tag `coffee -e "pkg = JSON.parse require('fs').readFileSync('package.json'); console.log 'v' + pkg.version"`

.PHONY: test watchdir tag
