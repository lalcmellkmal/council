all: out.js
	node out.js

clean:
	rm -f -- out.js

out.js: server.nl
	../nestless/nestless.js -v -o $@ $<
