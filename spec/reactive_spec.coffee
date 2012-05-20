expect = require 'expect.js'
rx     = require '../reactive'
global.Observable = rx.Observable

describe "Observable", ->
	describe ".any", ->
		it "should return true if there was a value", (done) ->
			Observable
				.range(1, 5)
				.any()
				.subscribe ((v) ->
					expect(v).to.be true), () -> done()

		it "should return false if there wasn't a value", (done) ->
			Observable
				.empty()
				.any()
				.subscribe ((v) ->
					expect(v).to.be false), () -> done()

	describe ".apply", ->
		it "should apply a function to the values", (done) ->
			i = 1
			fun = (x) -> x + 42

			Observable
				.range(1, 5)
				.apply(fun)
				.subscribe ((v) ->
					expect(v).to.equal fun i++), () -> done()

	describe ".buffer", ->
		it "should be tested"

	describe ".contains", ->
		it "should yield true if the value occurs", (done) ->
			i = 1

			Observable
				.range(1, 5)
				.contains(4)
				.subscribe ((v) ->
					if i++ isnt 4
						expect(v).to.be false
					else
						expect(v).to.be true), () -> done()

		it "should call complete if the value occurred", (done) ->
			i = 1

			Observable
				.range(1, 5)
				.contains(2)
				.subscribe ((v) -> i++), () ->
					expect(i).to.be 3
					done()

		it "should yield false if the value doesn't occur", (done) ->
			Observable
				.range(1, 5)
				.contains(42)
				.subscribe ((v) ->
					expect(v).to.be false), () -> done()

	it ".concat", (done) ->
		i = 1
		o1 = Observable.range 1, 5
		o2 = Observable.range 6, 10

		Observable
			.concat([o1, o2])
			.subscribe ((v) ->
				expect(i++).to.equal v), () -> done()

	describe ".count", ->
		it "should count how many values occurred", (done) ->
			Observable
				.range(1, 5)
				.count()
				.subscribe (v) ->
					expect(v).to.equal 5
					done()

	describe ".delay", ->
		it "should be tested"

	describe ".distinct", ->
		it "should only yield distinct values", (done) ->
			i = 0
			expected = [1, 20, 3, 5]

			Observable
				.fromList([1, 1, 1, 20, 1, 3, 1, 3, 3, 5])
				.distinct()
				.subscribe ((v) ->
					expect(v).to.equal expected[i++]), () ->
						expect(i).to.equal 4
						done()

	describe ".distinctUntilNot", ->
		it "should only yield distinct values until a non-distinct one occurs", (done) ->
			i = 0
			expected = [3, 1, 2]

			Observable
				.fromList([3, 1, 2, 1, 5])
				.distinctUntilNot()
				.subscribe ((v) ->
					expect(v).to.equal expected[i++]), () ->
						expect(i).to.equal 3
						done()

	describe ".drop", ->
		it "should fail for a parameter < 0"

		it "should drop the first n values", (done) ->
			i = 4

			Observable
				.range(1, 10)
				.drop(3)
				.subscribe ((v) ->
					expect(v).to.equal i++), () ->
						expect(i).to.equal 11
						done()

		it "should drop no values if n is 0", (done) ->
			i = 1

			Observable
				.range(1, 5)
				.drop(0)
				.subscribe ((v) ->
					expect(v).to.equal i++), () ->
						expect(i).to.equal 6
						done()

	describe ".dropWhile", ->
		it "should drop values while the condition returns true", (done) ->
			i = 5
			cond = (x) -> x < 5

			Observable
				.range(1, 10)
				.dropWhile(cond)
				.subscribe ((v) ->
					expect(v).to.equal i++), () ->
						expect(i).to.equal 11
						done()

		it "should not drop again after the condition was true once", (done) ->
			i = 0
			expected = [5, 6, 7, 8, 9, 10, 11, 12]
			cond = (x) ->
				if x < 5
					true
				else
					if x > 10
						true
					else
						false

			Observable
				.range(1, 12)
				.dropWhile(cond)
				.subscribe ((v) ->
					expect(v).to.equal expected[i++]), () ->
						expect(i).to.equal expected.length
						done()

	describe ".first", ->
		it "should yield only the first value", (done) ->
			i = 1

			Observable
				.range(1, 10)
				.first()
				.subscribe ((v) ->
					expect(v).to.equal i++), () ->
						expect(i).to.equal 2
						done()

	describe ".firstOf", ->
		it "should be tested"

	describe ".fold", ->
		it "should fold the values into one", (done) ->
			i = 0
			expected = [1, 3, 6, 10, 15]
			add = (x, y) -> x + y

			Observable
				.range(1, 5)
				.fold(add, 0)
				.subscribe ((v) ->
					expect(v).to.equal expected[i++]), () -> done()

	describe ".fromEvent", ->
		it "should be tested"

	describe ".fromList", ->
		it "should be tested"

	describe ".fromXMLHttpRequest", ->
		it "should be tested"

	describe ".merge", ->
		it "should yield the correct number of values", (done) ->
			o1 = Observable.range(1, 5)
			o2 = Observable.range(1, 5)

			Observable
				.merge([o1, o2])
				.count()
				.subscribe (v) ->
					expect(v).to.equal 10
					done()

		it "should yield values from the merged observables"

	describe "pace", ->
		it "should be tested"

	describe ".range", ->
		it "should generate a range from start to finish", (done) ->
			i = 1

			Observable
				.range(1, 5)
				.subscribe ((v) ->
					expect(v).to.equal i++), () ->
						expect(i).to.equal 6
						done()

		it "should generate a reverse range if start > finish", (done) ->
			i = 5

			Observable
				.range(5, 1)
				.subscribe ((v) ->
					expect(v).to.equal i--), () ->
						expect(i).to.equal 0
						done()

		it "should move with the specified steps", (done) ->
			i = 0

			Observable
				.range(0, 10, 2)
				.subscribe ((v) ->
					expect(v).to.equal i
					i += 2), () ->
						expect(i).to.equal 12
						done()

	describe ".returnValue", ->
		it "should return the value upon completion", (done) ->
			i = 5

			Observable
				.range(1, 3)
				.returnValue(5)
				.subscribe ((v) ->
					expect(v).to.equal i++), () ->
						expect(i).to.equal 6
						done()

	describe ".sample", ->
		it "should yield the correct number of values", (done) ->
			Observable
				.range(1, 10)
				.sample(2)
				.count()
				.subscribe (v) ->
					expect(v).to.equal 5
					done()

		it "should yield every nth value", (done) ->
			i = 0
			expected = [3, 6, 9]

			Observable
				.range(1, 10)
				.sample(3)
				.subscribe ((v) ->
					expect(v).to.equal expected[i++]), () ->
						expect(i).to.equal expected.length
						done()

	describe ".single", ->
		it "should return the value", (done) ->
			Observable
				.returnValue(42)
				.single()
				.subscribe (v) ->
					expect(v).to.equal 42
					done()

		it "should call error if there is more than one value"

	describe ".take", ->
		it "should yield the first n values", (done) ->
			i = 1

			Observable
				.range(1, 10)
				.take(3)
				.subscribe ((v) ->
					expect(v).to.equal i++), () ->
						expect(i).to.equal 4
						done()

	describe ".takeWhile", ->
		it "should yield values while the condition is true", (done) ->
			i = 1

			Observable
				.range(1, 10)
				.takeWhile((x) -> x < 5)
				.subscribe ((v) ->
					expect(v).to.equal i++), () ->
						expect(i).to.equal 5
						done()

	describe ".timeout", ->
		it "should be tested"

	describe ".timer", ->
		it "should be tested"

	describe ".timestamp", ->
		it "should be tested"

	describe ".throttle", ->
		it "should be tested"

	describe ".unfold", ->
		it "should be tested"

	describe ".where", ->
		it "should only yield values when the condition is true", (done) ->
			Observable
				.range(1, 10)
				.where((x) -> x % 2 == 0)
				.subscribe ((v) ->
					expect(v % 2).to.equal 0), () -> done()

	describe ".zip", ->
		it "should zip two observables", (done) ->
			i = 0
			expected = [2, 4, 6, 8, 10]
			o1 = Observable.range(1, 5)
			o2 = Observable.range(1, 5)

			o1.zip(o2, (x, y) -> x + y)
				.subscribe ((v) ->
					expect(v).to.equal expected[i++]), () ->
						expect(i).to.equal expected.length
						done()
