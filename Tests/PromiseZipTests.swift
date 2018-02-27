//
//  PromiseZipTests.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import XCTest
import Nimble
import DeLorean

final class PromiseZipTests: XCTestCase {

    func testZippingTwoPromises() {

        let promise1 = Promise(value: 0)
        let promise2 = Promise(value: "foobar")
        let zipped = Promise<Void>.zip(promise1, promise2)

        expect(zipped.value?.0).toEventually(equal(0))
        expect(zipped.value?.1).toEventually(equal("foobar"))
    }

    func testMultipleParameters() {

        let promise1 = Promise(value: 0)
        let promise2 = Promise(value: "foobar")
        let promise3 = Promise(value: [1, 3, 3, 7])
        let promise4 = Promise(value: ["foo", "bar"])
        let zipped = Promise<Void>.zip(promise1, promise2, promise3, promise4)

        expect(zipped.value?.0).toEventually(equal(0))
        expect(zipped.value?.1).toEventually(equal("foobar"))
        expect(zipped.value?.2).toEventually(equal([1, 3, 3, 7]))
        expect(zipped.value?.3).toEventually(equal(["foo", "bar"]))
    }
}
