Observer = class Observer
	constructor: (@next, @complete = (() -> undefined), @error = ((e) -> undefined)) ->

UnsubscribeWrapper = class UnsubscribeWrapper
	constructor: (@unsubscribeTarget, @observer) ->
	
	dispose: () ->
		ix = @unsubscribeTarget.observers.indexOf @observer
		unless ix is -1
			@unsubscribeTarget.observers.split ix, 1
		undefined

Observable = class Observable
	constructor: (@observableFunc) ->
		@observers = []
		@err = null

		@mainObserver = new Observer ((n) => @observers.forEach (o) -> o.next n), (() =>
			@observers.forEach (o) -> o.complete()
			@dispose()
		), ((e) =>
			@err = e
			@observers.forEach (o) -> o.error e
			@dispose())
	
	subscribe: (next, complete = null, error = null) ->
		unless @err == null
			error @err unless error == null
			return null

		if @mainObserver == null
			complete unless complete == null
			return null

		if typeof(next) == 'function'
			@_addObserver new Observer(next, complete, error)
		else if next.prototype == Observer
			@_addObserver next
		else
			throw Exception "Parameter 'next' must be a function or an Observer"

	_addObserver: (observer) ->
		@observers.push observer
		@observableFunc @mainObserver if @observers.length == 1
		new UnsubscribeWrapper @, observer

	dispose: () ->
		@mainObserver = null
		@observers = []
		undefined

	count: () -> Observable.count this
	contains: (value) -> Observable.contains this, value
	concat: (list) ->
		list.unshift this
		Observable.concat list
	fold: (foldFunc, initialValue) ->
		Observable.fold this, foldFunc, initialValue
	any: () -> Observable.any this
	buffer: (size = 10) -> Observable.buffer this, size
	delay: (milliseconds) -> Observable.delay this, milliseconds
	distinct: () -> Observable.distinct this
	distinctUntilNot: () -> Observable.distinctUntilNot this
	apply: (applyFunc) -> Observable.apply this, applyFunc
	merge: (sources) ->
		sources.unshift this
		Observable.merge sources
	zip: (right, zipFunc) -> Observable.zip this, right, zipFunc
	where: (condFunc) -> Observable.where this, condFunc
	timestamp: () -> Observable.timestampt this
	timeout: (milliseconds) -> Observable.timeout this, milliseconds
	throttle: (milliseconds) -> Observable.throttle this, milliseconds
	single: () -> Observable.single this
	first: () -> Observable.first this
	take: (howMany) -> Observable.take this, howMany
	takeWhile: (condFunc) -> Observable.takeWhile this, condFunc
	drop: (howMany) -> Observable.drop this, howMany
	dropWhile: (condFunc) -> Observable.dropWhile this, condFunc
	firstOf: (sources) ->
		sources.unshift this
		Observable.firstOf sources
	sample: (sampleFrequency) -> Observable.sample this, sampleFreuqency
	skip: (skipCount) -> Observable.skip this, skipCount
	fromXMLHttpRequest: (uri, reqHeader, reqValue) ->
		Observable.fromXMLHttpRequest uri, reqHeader, reqValue, this
	fromList: (list) -> Observable.fromList list, this
	timer: (milliseconds, ticks = -1) ->
		Observable.timer milliseconds, ticks, this
	unfold: (initialState, condFunc, iterateFunc, resultFunc) ->
		Observable.unfold initialState, condFunc, iterateFunc, resultFunc, this
	fromEvent: (element, eventName) -> Observable.fromEvent element, eventName, this
	returnValue: (value) -> Observable.returnValue value, this
	range: (start, finish, step = 1) ->
		Observable.range start, finish, step, this
	pace: (paceInMilliseconds) ->
		Observable.pace this, paceInMilliseconds
	animationFrame: (interval = 0) ->
		Observable.animationFrame interval, this

	@create: (observableFunc) ->
		new Observable observableFunc

	@animationFrame: (interval = 0, continuation) ->
		return Observable.throwE(new Exception "Parameter 'interval' cannot be < 0") if interval < 0

		return Observable.create (o) ->
			makeIt = () ->
				if interval == 0
					_loop = (time) ->
						requestAnimFrame _loop
						o.next time
					requestAnimFrame _loop
				else
					lastTime = 0

					loopInterval = (time) ->
						requestAnimFrame loopInterval
						if (time - lastTime >= interval)
							o.next time
							lastTime = time
					requestAnimFrame loopInterval

			if continuation == null
				makeIt()
			else
				continuation.subscribe (() -> undefined), (() -> makeIt()), (e) -> o.error e
	
	@pace: (source, paceInMilliseconds) ->
		return Observable.throwE(new Exception "Parameter 'paceInMilliseconds must be >= 1'") if paceInMilliseconds < 1

		return Observable.create (o) ->
			buf = new Queue()
			isComplete = false

			paceIt = () ->
				if buf.isEmpty() and isComplete
					o.complete()
					return
				else
					o.next buf.removeFirst()

				setTimeout paceIt, paceInMilliseconds

			source.subscribe ((v) -> buf.add v), (() -> isComplete = true), (e) -> o.error e

			paceIt()

	@skipWhile: (source, condFun) ->
		return Observable.create (o) ->
			counter = 0
			trueFlag = true

			source.subscribe ((v) ->
				if not trueFlag
					o.next v
				else
					if not isTrue(v)
						trueFlag = false
						o.next v
			), (() -> o.complete()), (e) -> o.error(e)

	@skip: (source, skipCount = 0) ->
		return Observable.throwE(new Exception "Parameter 'skipCount' must be >= 0") if skipCount < 0

		return Observable.create (o) ->
			counter = 0

			source.subscribe ((v) ->
				if counter++ >= skipCount
					o.next v
			), (() -> o.complete()), (e) -> o.error e

	@sample: (source, sampleFrequency = 1) ->
		return Observable.throwE(new Exception "Parameter 'sampleFrequency' must be >= 1") if sampleFreqency < 1

		return Observable.create (o) ->
			counter = 0

			source.subscribe ((v) ->
				if ++counter == sampleFrequency
					o.next v
					counter = 0
			), (() -> o.complete()), (e) -> o.error e
	
	@firstOf: (sources) ->
		return Observable.create (o) ->
			sources.forEach (source) ->
				d = source.subscribe ((v) ->
					if firstIn == null
						firstIn = source
						o.next v
					else
						if firstIn != source
							d.dispose() if d != null
						else
							o.next v
				), (() ->
					if firstIn != null and source == firstIn
						o.complete()
				), (e) -> o.error e

	@randomInt: (low, high, intervalLow = 1, intervalHigh = 1, howMany = null, continuation = null) ->
		return Observable.create (o) ->
			makeIt = () ->
				Observable
					.random(low, high, intervalLow, intervalHigh, howMany)
					.apply((v) -> v.ceil)
					.subscribe ((v) -> o.next v), (() -> o.complete), (e) -> o.error e

			if continuation == null
				makeIt()
			else
				continuation.subscribe (() -> undefined), (() -> makeIt), (e) -> o.error e
	
	@random: (low, high, intervalLow = 1, intervalHigh = 1, howMany = null, continuation = null) ->
		return Observable.throwE(new Exception "Parameter 'high' must be > parameter 'low'") if high <= low
		return Observable.throwE(new Exception "Parameter 'intervalHigh' must be > parameter 'intervalLow'") if intervalHigh < intervalLow
		return Observable.throwE(new Exception "timer interval parameters must be >= 1") if intervalLow < 1 or intervalHigh < 1

		delta = high - low
		intervalDelta = intervalHigh - intervalLow
		ticks = 0

		iFunc = () ->
			if intervalDelta == 0
				() -> intervalLow
			else
				() -> Math.random() * intervalDelta + intervalLow

		return Observable.create (o) ->
			makeIt = () ->
				nextNum = () ->
					o.next Math.random() * delta + low

					if howMany == null
						setTimeout nextNum, iFunc()
					else if howMany != null && ++ticks <= howMany
						setTimeout nextNum, iFunc()
					else
						o.complete()

				if howMany == null
					setTimeout nextNum, iFunc()
				else if howMany != null && ++ticks <= howMany
					setTimeout nextNum, iFunc()
				else
					o.complete()

			if continuation == null
				makeIt()
			else
				continuation.subscribe (() -> undefined), (() -> makeIt), (e) -> o.error e

	@fromXMLHttpRequest: (uri, requestHeader, requestValue, continuation = null) ->
		return Observable.create (o) ->
			makeIt = () ->
				req = new XMLHttpRequest()

				Observable
					.fromEvent(req, 'error')
					.subscribe (e) ->
						o.error new Exception "Error occurred during XMLHttpRequest"

				Observable
					.fromEvent(req, 'readystatechange')
					.subscribe (ev) ->
						return if req.readyState != 4

						o.next req.responseText
						o.complete

				try
					req.open 'GET', uri, true
					req.setRequestHeader requestHeader, requestValue
					req.send()
				catch e
					o.error e

			if continuation == null
				makeIt()
			else
				continuation.subscribe (() -> undefined), (() -> makeIt), (e) -> o.error e
	
	@takeWhile: (source, condFunc) ->
		return Observable.create (o) ->
			source.subscribe ((v) ->
				if not condFunc(v)
					o.complete()
				else
					o.next v
			), (() -> o.complete()), (e) -> o.error e
	
	@take: (source, howMany) ->
		return Observable.throwE(new Exception "Parameter 'howMany' must be > 0") if howMany < 0

		return Observable.empty() if howMany == 0

		count = 0

		return Observable.create (o) ->
			source.subscribe ((v) ->
				if ++count == howMany
					o.next v
					o.complete()
				else
					o.next v
			), (() -> o.complete()), (e) -> o.error e

	@drop: (source, howMany) ->
		return Observable.throwE(new Exception "Parameter 'howMany' must be > 0") if howMany < 0

		return Observable.empty() if howMany == 0

		count = 0

		return Observable.create (o) ->
			source.subscribe ((v) ->
				o.next v if ++count > howMany
			), (() -> o.complete()), (e) -> o.error e

	@dropWhile: (source, condFunc) ->
		dropping = true

		return Observable.create (o) ->
			source.subscribe ((v) ->
				if dropping and not condFunc(v)
					dropping = false
				o.next v unless dropping
			), (() -> o.complete()), (e) -> o.error e

	@first: (source) ->
		return Observable.create (o) ->
			source.subscribe ((v) ->
				o.next v
				o.complete()
			), (() -> o.complete()), (e) -> o.error e
	
	@single: (source) ->
		return Observable.create (o) ->
			gotOne = false

			source.subscribe ((v) ->
				return o.error new Exception "Error: source returned more than one element in Observable.single()" if gotOne

				gotOne = true
				o.next v
			), (() -> o.complete()), (e) -> o.error e
	
	@returnValue: (value, continuation = null) ->
		return Observable.create (o) ->
			makeIt = () ->
				o.next value
				o.complete()

			if continuation == null
				makeIt()
			else
				continuation.subscribe (() -> undefined), (() -> makeIt), (e) -> o.error e
	
	@range: (start, finish, step = 1, continuation = null) ->
		return Observable.throwE(new Exception "Parameter 'step' must be > 0") if step <= 0

		return Observable.returnValue start if start == finish

		if start < finish
			Observable.unfold start, ((v) -> v <= finish), ((v) -> v += step), ((v) -> v), continuation
		else
			Observable.unfold start, ((v) -> v >= finish), ((v) -> v -= step), ((v) -> v), continuation

	@unfold: (initialState, condFunc, iterate, result, continuation = null) ->
		return Observable.create (o) ->
			makeIt = () ->
				s = initialState

				try
					while condFunc(s)
						o.next result(s)
						s = iterate(s)
					o.complete()
				catch e
					o.error e

			if continuation == null
				makeIt()
			else
				continuation.subscribe (() -> undefined), (() -> makeIt), (e) -> o.error e

	@throttle: (source, timeInMilliseconds) ->
		return Observable.create (o) ->
			ignoreValue = false;
			checker = () ->
				ignoreValue = false
				o.next last if last != null

			source.subscribe ((v) ->
				if not ignoreValue
					last = v
					ignoreValue = true
					handle = setTimeout checker, timeInMilliseconds
				else
					clearTimeout handle
					last = v
					handle = setTimeout checker, timeInMilliseconds
			), (() -> o.complete()), (e) -> o.error e

	@timeout: (source, timeoutInMilliseconds) ->
		return Observable.create (o) ->
			checker = () -> o.error new Exception "Error: Timeout exceeded"

			source.subscribe ((v) ->
				clearTimeout handler
				o.next v
				handler = setTimeout checker timeoutInMilliseconds
			), (() -> o.complete()), (e) -> o.error e

			handler = setTimeout checker, timeoutInMilliseconds

	@timestamp: (source) ->
		return Observable.create (o) ->
			source.subscribe ((v) -> o.next new Date.now()), (() -> o.complete()), (e) -> o.error e

	@toList: (source) ->
		list = []

		return Observable.create (o) ->
			source.subscribe ((v) -> list.push v), (() ->
				o.next list, o.complete()), (e) -> o.error e

	@fromEvent: (element, eventName, continuation = null) ->
		addListener = (element.addEventListener || element.on).bind element

		return Observable.create (o) ->
			makeIt = () ->
				addListener eventName, ((ev) -> o.next ev), false

			if continuation == null
				makeIt()
			else
				continuation.subscribe (() -> undefined), (() -> makeIt), (e) -> o.error e
	
	@never: () ->
		Observable.create (o) -> undefined

	@throwE: (exception) ->
		Observable.create (o) -> o.error exception

	@count : (source) ->
		count = 0

		return Observable.create (o) ->
			source.subscribe ((v) -> ++count), (() ->
				o.next count
				o.complete()
			), (e) -> o.error e

	@apply: (source, applyFunc) ->
		return Observable.create (o) ->
			source.subscribe ((v) -> o.next applyFunc(v)), (() -> o.complete()), (e) -> o.error e

	@distinctUntilNot: (source) ->
		seen = []

		return Observable.create (o) ->
			source.subscribe ((v) ->
				if not v in seen
					seen.push v
					o.next v
				else
					o.complete()
			), (() -> o.complete()), (e) -> o.error e

	@where: (source, filterFunc) ->
		return Observable.create (o) ->
			source.subscribe ((v) ->
				o.next v if filterFunc v), (() -> o.complete()), (e) -> o.error e

	@zip: (left, right, zipFunc) ->
		leftQueue = []
		rightQueue = []

		return Observable.create (o) ->
			nextQueueFunc = (ownQueue, otherQueue) ->
				(v) ->
					ownQueue.push v
					o.next zipFunc(ownQueue.shift(), otherQueue.shift()) unless otherQueue.length == 0

			completeQueueFunc = (ownQueue, otherDisposable) ->
				() ->
					if ownQueue.length == 0
						o.complete()
						otherDisposable.dispose()

			leftDisposable = left.subscribe nextQueueFunc(leftQueue, rightQueue),
				completeQueueFunc(leftQueue, rightDisposable), (e) -> o.error e

			rightDisposable = right.subscribe nextQueueFunc(rightQueue, leftQueue),
				completeQueueFunc(rightQueue, leftDisposable), (e) -> o.error e

	@merge: (sources) ->
		t = 0

		return Observable.create (o) ->
			sources.forEach (source) ->
				source.subscribe ((v) -> o.next v),
					(() -> o.complete() if ++t == sources.length),
					(e) -> o.error e

	@distinct: (source) ->
		seen = []

		return Observable.create (o) ->
			source.subscribe ((v) ->
				unless v in seen
					seen.push v
					o.next v
			), (() -> o.complete()), (e) -> o.error(e)

	@delay: (source, milliseconds) ->
		buf = []
		delaying = true

		t = Observable.timer milliseconds, 1
		t.subscribe ((v) -> undefined), (() -> delaying = false)

		return Observable.create (o) ->
			source.subscribe ((v) ->
				if not delaying
					if not buf.length == 0
						buf.forEach (b) -> o.next b
						buf = []
					else
						o.next v
				else
					buf.push v
			), (() ->
				t.subscribe ((v) -> undefined), (() ->
					if not buf.length == 0
						buf.forEach (b) -> o.next b
						buf = []
					o.complete())
			), (e) -> o.error e

	@contains: (source, value) ->
		return Observable.create (o) ->
			source.subscribe ((v) ->
				if v != value
					o.next false
				else
					o.next true
					o.complete()
			), (() -> o.complete()), (e) -> o.error e

	@empty: () ->
		Observable.create (o) -> o.complete()

	@fold: (source, foldFunc, initialValue) ->
		return Observable.create (o) ->
			acc = initialValue
			source.subscribe ((v) ->
				acc = foldFunc acc, v
				o.next acc
			), (() -> o.complete()), (e) -> o.error e

	@any: (source) ->
		return Observable.create (o) ->
			source.subscribe ((v) ->
				o.next true
				o.complete()
			), (() ->
				o.next false
				o.complete()
			), (e) -> o.error e

	@buffer: (source, size = 10) ->
		buf = []

		return Observable.create (o) ->
			source.subscribe ((v) ->
				buf.add v
				if buf.length == size
					o.next buf
					buf = []
			), (() ->
				unless buf.length == 0
					o.next buf
					buf = []
				o.complete()
			), (e) -> o.error e

	@contains: (sources) ->
		return Observable.empty() if not sources? or sources.length == 0

		return Observable.create (o) ->
			_concat = (observer, srcs, index) ->
				srcs[index].subscribe ((v) -> observer.next v), (() ->
					if ++index < srcs.length
						_concat o, srcs, index
					else
						observer.complete()
				), (e) -> observer.error e

			_concat o, sources, 0

	@fromList: (list, continuation = null) ->
		return Observable.create (o) ->
			makeIt = () ->
				list.forEach (el) -> o.next el
				o.complete()

			if continuation == null
				makeIt()
			else
				continuation.subscribe (() -> undefined), (() -> makeIt), (e) -> o.error e

	@timer: (milliseconds, ticks = -1, continuation = null) ->
		return Observable.throwE(new Exception "Parameter 'milliseconds' must be >= 1") if milliseconds < 1

		return Observable.create (o) ->
			makeIt = () ->
				if ticks <= 0
					setInterval (() -> o.next null), milliseconds
				else
					tickCount = 0

					handler = setInterval (() ->
						if ++tickCount > ticks
							clearInterval handler
							o.complete()
							return
						o.next tickCount
					), milliseconds

			if continuation == null
				makeIt()
			else
				continuation.subscribe (() -> undefined), (() -> makeIt), (e) -> o.error e

try
	window.Observer = Observer
	window.UnsubscribeWrapper = UnsubscribeWrapper
	window.Observable = Observable
catch e
	module.exports = {
		Observer: Observer,
		UnsubscribeWrapper: UnsubscribeWrapper,
		Observable: Observable
	}
