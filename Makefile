all: fetch-coffeescript

fetch-coffeescript:
	curl http://coffeescript.org/extras/coffee-script.js -o coffee-script.js
