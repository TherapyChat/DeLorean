//
//  PromiseRetryTests.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import XCTest
import Nimble
import DeLorean

final class PromiseRetryTests: XCTestCase {

    func testRetry() {

        var currentCount = 3
        let promise = Promise<Int>.retry(attempt: 3) { () -> Promise<Int> in
            guard currentCount != 1 else { return Promise(value: 8) }
            currentCount -= 1
            return Promise(error: SimpleError())
        }

        expect(promise.value).toEventually(equal(8))
        expect(promise.isFulfilled).toEventually(beTrue())
    }

    func testRetryWithInstantSuccess() {

        var currentCount = 1
        let promise = Promise<Int>.retry(attempt: 3) { () -> Promise<Int> in
            if currentCount == 0 { fail() }
            currentCount -= 1
            return Promise(value: 8)
        }

        expect(promise.value).toEventually(equal(8))
        expect(promise.isFulfilled).toEventually(beTrue())
    }

    func testRetryWithNeverSuccess() {

        let promise = Promise<Int>.retry(attempt: 3) { () -> Promise<Int> in
            return Promise(error: SimpleError())
        }

        expect(promise.isRejected).toEventually(beTrue())
    }
}
