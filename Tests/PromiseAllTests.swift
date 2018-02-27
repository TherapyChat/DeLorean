//
//  PromiseAllTests.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import XCTest
import Nimble
import DeLorean

final class PromiseAllTests: XCTestCase {

    func testAll() {

        let promise1 = Promise(value: 1)
        let promise2 = Promise<Int> { future in
            delay(0.05) { future(.fulfill(2)) }
        }
        let promise3 = Promise<Int> { future in
            delay(0.1) { future(.fulfill(3)) }
        }
        let promise4 = Promise<Int> { future in
            delay(0.09) { future(.fulfill(4)) }
        }

        let final = Promise<Int>.all([promise1, promise2, promise3, promise4])

        expect(final.value).toEventually(equal([1, 2, 3, 4]))
        expect(final.isFulfilled).toEventually(beTrue())
    }

    func testAllWithPreFulfilledValues() {

        let promise1 = Promise(value: 1)
        let promise2 = Promise(value: 2)
        let promise3 = Promise(value: 3)

        let final = Promise<Int>.all([promise1, promise2, promise3])

        expect(final.value).toEventually(equal([1, 2, 3]))
        expect(final.isFulfilled).toEventually(beTrue())
    }

    func testAllWithEmptyArray() {

        let final: Promise<[Int]> = Promise<Int>.all([])
        waitUntil { final.always($0) }

        expect(final.value).toEventually(equal([]))
        expect(final.isFulfilled).toEventually(beTrue())
    }

    func testAllWithRejectionHappeningFirst() {

        let promise1 = Promise<Int> { future in
            delay(0.1) { future(.fulfill(2)) }
        }
        let promise2 = Promise<Int> { future in
            delay(0.05) { future(.reject(SimpleError())) }
        }

        let final = Promise<Int>.all([promise1, promise2])

        expect(final.error).toNotEventually(beNil())
        expect(final.isRejected).toEventually(beTrue())
    }

    func testAllWithRejectionHappeningLast() {

        let promise1 = Promise<Int> { future in
            delay(0.1) { future(.fulfill(2)) }
        }
        let promise2 = Promise<Int> { _ in
            throw SimpleError()
        }

        let final = Promise<Int>.all([promise1, promise2])

        expect(final.error).toNotEventually(beNil())
        expect(final.isRejected).toEventually(beTrue())
    }
}
