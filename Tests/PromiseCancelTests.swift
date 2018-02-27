//
//  PromiseCancelTests.swift
//  DeLoreanTests
//
//  Created by sergio on 26/02/2018.
//  Copyright © 2018 nc43tech. All rights reserved.
//

import XCTest
import Nimble
import DeLorean

final class PromiseCancelTests: XCTestCase {

    func testCancel() {

        let promise = Promise<Int> { future in
            future(.cancel)
        }

        expect(promise.isCancelled).toEventually(beTrue())
    }

    func testCancelIsInvoked() {
        var isCancelCalled = false

        let promise = Promise<Int> { _, _, _, cancel in
            cancel()
            }

        promise.cancel { 
            isCancelCalled = true
        }

        expect(isCancelCalled).toEventually(beTrue())
    }

    func testCancelAfterFulfill() {

        let promise = Promise(value: 0)
        promise.cancel()

        expect(promise.isCancelled).toEventually(beFalse())
    }

    func testCancelCombinedWithThen() {
        var isCancelCalled = false

        let promise = Promise { future in
            future(.progress(0))
            future(.cancel)
            future(.fulfill(1))
            }.then({ value in
                expect(value).to(equal(1))
            }, { error in
                expect(error).toNot(beNil())
            }, { value in
                expect(value).to(equal(0))
            }, {
                isCancelCalled = true
            })

        expect(promise.isCancelled).toEventually(beTrue())
        expect(isCancelCalled).toEventually(beTrue())
        expect(promise.value).toEventually(beNil())
    }

    func testCancelOnThrowable() {

        let promise = Promise<Int> { _, _, _, cancel in
            cancel()
            throw SimpleError()
        }

        expect(promise.isCancelled).toEventually(beTrue())
        expect(promise.isRejected).toEventually(beFalse())
    }

    func testCancelAfterThen() {
        var cancelWasCalled = false
        let promise = Promise<Int> { progress, _, _, cancel in
            progress(0)
            cancel()
            }.then({
                expect($0).to(equal(0))
            }).progress({
                expect($0).to(equal(0))
            }).cancel({
                cancelWasCalled = true
        })
        expect(cancelWasCalled).toEventually(beTrue())
        expect(promise.isCancelled).toEventually(beTrue())
    }
}
