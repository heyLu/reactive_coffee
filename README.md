# Reactive coffee

**TODO**: Insert cool logo here!

An implementation of Reactive Extensions for *Your Language Here* in
Coffeescript. It is directly adapted from [the one for Dart][rx-dart]
because Dart can't compile libraries to Javascript, which is sad.

So... here it is!

## TODO

 * a logo (see above)
 * pick a license (probably has to be the one from Reactive Dart)
 * more examples
 * tests
 * real world usage (working on this ;)
 * **DOCS**

## Examples

### Playing with lists

Actually, these are just plain old Javascript arrays, support for
NodeList and friends might come later (write it, I'll be glad to merge
it in :).

    > Observable.fromList([1,2,3,4]).subscribe (v) -> console.log v
    1
    2
    3
    4

Be picky about the elements in the list:

    > Observable.fromList([1,2,3,4,5,6,7,8,9])
        .where((v) -> v % 2 = 0)
        .subscribe (v) -> console.log v
    2
    4
    6
    8

Or use `range` and `takeWhile`:

    > Observable.range(1, 100)
        .takeWhile((v) -> v < 42) # Don't give 'em the answer!
        .subscribe (v) -> console.log v
    1
    2
    3
    4
    5
    6
    7
    8
    9
    10
    11
    12
    13
    14
    15
    16
    17
    18
    19
    20
    21
    22
    23
    24
    25
    26
    27
    28
    29
    30
    31
    32
    33
    34
    35
    36
    37
    38
    39
    40
    41

Well, there are more interesting things than lists...

### XMLHttpRequests are fun, too

    # Load up reactive.html in your browser to try this out
    > Observable.fromXMLHttpRequest('file:///path/to/reactive_coffee/Makefile')
        .subscribe (v) -> console.log v
    all: fetch-coffeescript
    
    fetch-coffeescript:
        curl http://coffeescript.org/extras/coffee-script.js -o coffee-script.js

### And finally... events

Prevent the user from clicking something too often.

    > Observable.fromEvent(document, 'click')
        .take(3)
        .subscribe ((v) -> console.log v), (() -> console.log "finished!")

## API

See [Reactive Dart][rx-dart] for now, apart from `fromIsolate`
everything should be supported.

[rx-dart]: https://github.com/prujohn/Reactive-Dart
