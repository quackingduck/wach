compile-coffee:
	./node_modules/.bin/coffee --compile --lint --output lib src

compile-watchdir:
	clang -Wall -framework CoreServices -o bin/wach-watchdir src/watchdir.c
