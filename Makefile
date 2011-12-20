lib-js:
	./node_modules/.bin/coffee --compile --lint --output lib src

watchdir:
	clang -Wall -framework CoreServices -o bin/wach-watchdir src/watchdir.c
