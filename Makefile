compile-coffee:
	./node_modules/.bin/coffee --compile --lint --output lib src

compile-watchdir:
	cc -Wall -framework CoreServices -o bin/wach-watchdir src/watchdir.c
