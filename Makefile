all: reactive.js reactive.min.js fetch-coffeescript

help:
	@echo -e "all\t  -  Compile to Javascript, minify (and fetch Coffeescript for local development)"
	@echo -e "release\t  -  Release a new reactive version (invoke as 'make RELEASE=a-number release')"
	@echo -e "love\t  -  Not yet supported, sorry."

reactive.js: reactive.coffee
	coffee -c reactive.coffee

reactive.min.js: reactive.js
	uglifyjs reactive.js > reactive.min.js

fetch-coffeescript:
	curl http://coffeescript.org/extras/coffee-script.js -o coffee-script.js

release: reactive.js reactive.min.js
	@if [ "$(RELEASE)" = "" ]; then \
		echo "***";\
		echo "*** Thou shalt invoke 'make RELEASE=a-number' upon releasing reactive to the world!";\
		echo "***";\
		exit 1;\
	fi
	@echo "YAY! Fear no more event-troubled programmer, reactive v$(RELEASE) has been released!"
	@echo
	@echo "Thanks for your hard work! "
	@git tag v$(RELEASE)
