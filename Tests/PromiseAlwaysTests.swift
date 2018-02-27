//
//  PromiseAlwaysTests.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import XCTest
import Nimble
import DeLorean

final class PromiseAlwaysTests: XCTestCase {

    func testAlways() {

        let promise = Promise<Int> { future in
            future(.fulfill(5))
        }

        waitUntil { promise.always($0) }

        expect(promise.isFulfilled).toEventually(beTrue())
    }

    func testAlwaysRejects() {

        let promise = Promise<Int> { _, _, reject, _ in
            reject(SimpleError())
        }

        waitUntil { promise.always($0) }

        expect(promise.isRejected).toEventually(beTrue())
    }

    func testAlwaysInstantFulfill() {

        let promise = Promise(value: 5)

        waitUntil { promise.always($0) }

        expect(promise.isFulfilled).toEventually(beTrue())
    }

    func testAlwaysInstantReject() {

        let promise = Promise<Int>(error: SimpleError())

        waitUntil { promise.always($0) }

        expect(promise.isRejected).toEventually(beTrue())
    }
    
}
