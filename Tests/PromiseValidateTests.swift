//
//  PromiseValidateTests.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import XCTest
import Nimble
import DeLorean

final class PromiseValidateTests: XCTestCase {

    func testValidationRejects() {

        let promise = Promise(value: 2)
            .validate { $0 == 3 }

        expect(promise.isRejected).toEventually(beTrue())
    }

    func testValidationSucceeds() {

        let promise = Promise(value: 3)
            .validate { $0 == 3 }

        expect(promise.value).toEventually(equal(3))
        expect(promise.isFulfilled).toEventually(beTrue())
    }

    func testEnsureOnlyCalledOnSucceess() {

        let promise = Promise<Int>(error: SimpleError())
            .validate { _ in fail(); return true }

        expect(promise.error).toEventuallyNot(beNil())
    }
    
}
