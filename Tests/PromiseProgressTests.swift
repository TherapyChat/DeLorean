//
//  PromiseProgressTests.swift
//  DeLoreanTests
//
//  Created by sergio on 14/02/2018.
//  Copyright © 2018 nc43tech. All rights reserved.
//

import XCTest
import Nimble
import DeLorean

final class PromiseProgressTests: XCTestCase {

    func testProgress() {

        let promise = Promise<Int> { future in
            future(.progress(1))
            future(.progress(2))
            future(.fulfill(3))
        }

        waitUntil { promise.always($0) }

        expect(promise.isFulfilled).toEventually(beTrue())
    }

    func testProgressRejects() {
        var counter = 0

        let promise = Promise<Int> { future in
            future(.reject(SimpleError()))
            future(.progress(0))
            }
            .progress { _ in counter += 1 }

        expect(counter).toEventually(equal(0))
        expect(promise.isRejected).toEventually(beTrue())
    }

    func testProgressCalledTwiceAndFulfill() {
        var counter = 0
        let _ = Promise<String> { progress, fulfill, reject, cancel in
            progress("foo")
            progress("bar")
            fulfill("foobar")
            reject(SimpleError())
            cancel()
        }.progress { _ in counter += 1 }

        expect(counter).toEventually(equal(2))
    }

    func testProgressAfterFullfill() {
        let promise: Promise<Bool> = Promise(value: "foobar")
            .then({ value in
                return Promise(future: { future in
                    future(.progress(Int(value.count)))
                }).progress({ count in
                    expect(count).to(equal(6))
                }).then({
                    return Promise(value: $0 > 0)
                })
            })

        expect(promise.isPending).toEventually(beTrue())
        expect(promise.value).toEventually(beNil())
    }

}
