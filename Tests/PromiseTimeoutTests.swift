//
//  PromiseTimeoutTests.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import XCTest
import Nimble
import DeLorean

final class PromiseTimeoutTests: XCTestCase {
    
    func testDelay() {

        let earlyPromise = Promise<Void>.delay(0.2)
        let laterPromise = Promise<Void>.delay(1.1)

        expect(earlyPromise.isPending).to(beTrue())
        expect(laterPromise.isPending).to(beTrue())
        expect(laterPromise.isPending).toEventually(beTrue())
        expect(earlyPromise.isFulfilled).toEventually(beTrue())
    }

    func testTimeoutPromise() {

        let earlyPromise: Promise<Void> = Promise<Void>.timeout(0.2)
        let laterPromise: Promise<Void> = Promise<Void>.timeout(1.1)

        expect(earlyPromise.isPending).to(beTrue())
        expect(laterPromise.isPending).to(beTrue())
        expect(laterPromise.isPending).toEventually(beTrue())
        expect(earlyPromise.isRejected).toEventually(beTrue())
    }

    func testTimeoutFunctionSucceeds() {

        let promise = Promise<Int> { future in
            delay(0.01) { future(.fulfill(5)) }
        }.timeout(1)

        expect(promise.isPending).to(beTrue())
        expect(promise.isFulfilled).toEventually(beTrue())
    }


    func testTimeoutFunctionFails() {

        let promise = Promise<Int> { future in
            delay(1) { future(.fulfill(5)) }
        }.timeout(0.5)

        expect(promise.isPending).to(beTrue())
        expect(promise.isRejected).toEventually(beTrue())
    }
}
