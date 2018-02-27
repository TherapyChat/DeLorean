//
//  PromiseThenTests.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import XCTest
import Nimble
import DeLorean

final class PromiseThenTests: XCTestCase {

    func testThen() {

        var count = 0
        
        let promise = Promise(value: ())
            .then {
                count += 1
            }.then {
                count += 1
        }

        expect(count).toEventually(equal(2))
        expect(promise.isFulfilled).toEventually(beTrue())
    }
    
    func testAsync() {

        let promise = Promise<String> { future in
            delay(0.05) { future(.fulfill("foobar")) }
        }

        var value = ""
        promise.then { string in
            value = string
        }

        expect(value).toEventually(equal("foobar"))
    }

    func testAsyncThrowing() {

        let promise = Promise<String> { _ in
            throw SimpleError()
        }

        expect(promise.error).toEventuallyNot(beNil())
        expect(promise.error as? SimpleError).toEventually(equal(SimpleError()))
    }
    
    func testAsyncRejection() {

        let promise = Promise<String> { _, _, reject, _ in
            delay(0.05) { reject(SimpleError()) }
            }.then { _ in fail()
            }.then { fail()
            }.then { fail()
            }.then { fail()
        }

        expect(promise.error).toEventuallyNot(beNil())
        expect(promise.isRejected).toEventually(beTrue())
    }
    
    func testThenWhenPending() {

        var thenCalled = false
        
        Promise().then {
            thenCalled = true
        }

        expect(thenCalled).toEventually(beFalse())
    }
    
    func testRejectedAfterFulfilled() {

        var thenCalled = false
        var thenCalledAgain = false

        let promise = Promise(value: 5)
            .then({ value in
                thenCalled = true
            }).then({ value in
                thenCalledAgain = true
            })

        promise.reject(SimpleError())

        expect(thenCalled).toEventually(beTrue())
        expect(thenCalledAgain).toEventually(beTrue())
        expect(promise.isFulfilled).toEventually(beTrue())
    }
    
    func testPending() {
        let promise = Promise<Int>()
        
        expect(promise.isPending).to(beTrue())
    }
    
    func testFulfilled() {

        let promise = Promise<Int>()
        
        promise.then { value in
            expect(value).to(equal(10))
        }
        
        promise.fulfill(10)

        expect(promise.value).toEventually(equal(10))
        expect(promise.isFulfilled).toEventually(beTrue())
    }
    
    func testRejected() {

        let error = SimpleError()
        let promise = Promise<Int>()

        promise.reject(error)

        expect(promise.error as? SimpleError).toEventually(equal(error))
        expect(promise.isRejected).toEventually(beTrue())
    }

    func testMap() {

        let promise = Promise(value: "someString")
            .then { string in
                return string.count
            }.then { count in
                return count*2
            }.then { doubled -> Promise<Int> in
                expect(doubled).to(equal(20))
                return Promise(value: doubled)
        }

        expect(promise.value).toEventually(equal(20))
        expect(promise.isFulfilled).toEventually(beTrue())
    }
    
    func testFlatMap() {

        let promise = Promise<String>(resolvers: { _, fulfill, reject, _ in
            delay(0.05) { fulfill("hello") }
        }).then({ value in
            return Promise<Int>(resolvers: { _, fulfill, reject, _ in
                delay(0.05) { fulfill(value.count) }
            })
        }).then({ value in
            expect(value).to(equal(5))
        })

        expect(promise.value).toEventually(equal(5))
        expect(promise.isFulfilled).toEventually(beTrue())
    }

    func testTrailingClosuresCompile() {

        let promise = Promise<String> { _, fulfill, reject, _ in
            delay(0.05) { fulfill("hello") }
            }.then { value in
                return Promise<Int> { _, fulfill, reject, _ in
                    delay(0.05) { fulfill(value.count) }
                }
            }.then { value in
                return value + 1
        }

        expect(promise.value).toEventually(equal(6))
        expect(promise.isFulfilled).toEventually(beTrue())
    }

    func testZalgoContained() {
        var called = false
        let promise = Promise(value: "asdf").then({ string in
            expect(called).to(beTrue())
        })
        called = true

        waitUntil { promise.always($0) }
    }

    func testDoubleResolve() {
        let promise = Promise<String>()
        promise.fulfill("correct")
        promise.fulfill("incorrect")

        expect(promise.value).to(equal("correct"))
    }
    
    func testRejectThenResolve() {
        let promise = Promise<String>()
        promise.reject(SimpleError())
        promise.fulfill("incorrect")

        expect(promise.isRejected).to(beTrue())
    }

    func testDoubleReject() {
        let promise = Promise<String>()
        promise.reject(SimpleError())
        promise.reject(SimpleError())

        expect(promise.isRejected).to(beTrue())
    }
    
    func testResolveThenReject() {
        let promise = Promise<String>()
        promise.fulfill("correct")
        promise.reject(SimpleError())

        expect(promise.value).to(equal("correct"))
    }

}
