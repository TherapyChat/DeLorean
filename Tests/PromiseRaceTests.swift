//
//  PromiseRaceTests.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import XCTest
import Nimble
import DeLorean

final class PromiseRaceTests: XCTestCase {
    
    func testRace() {
        let promise1 = Promise<Int> { future in
            delay(0.1) { future(.fulfill(1)) }
        }
        let promise2 = Promise<Int> { future in
            delay(0.2) { future(.fulfill(2)) }
        }
        let promise3 = Promise<Int> { future in
            delay(0.3) { future(.fulfill(3)) }
        }
        
        let final = Promise<Int>.race([promise1, promise2, promise3])

        expect(final.value).toEventually(equal(1))
        expect(final.isFulfilled).toEventually(beTrue())
    }
    
    func testRaceFailure() {

        let promise1 = Promise<Int>(error: SimpleError())
        let promise2 = Promise<Int>.delay(0.2).then { 2 }
        
        let final = Promise<Int>.race([promise1, promise2])

        expect(final.isRejected).toEventually(beTrue())
    }
    
    func testInstantResolve() {
        let promise1 = Promise<Int>(value: 1)
        let promise2 = Promise<Void>.delay(0.1).then { 5 }
        
        let final = Promise<Int>.race([promise1, promise2])

        expect(final.isFulfilled).toEventually(beTrue())
        expect(final.value).toEventually(equal(1))
    }
    
    func testInstantReject() {
        let promise1 = Promise<Int>(error: SimpleError())
        let promise2 = Promise<Int>.delay(0.1).then { 5 }
        
        let final = Promise<Int>.race([promise1, promise2])

        expect(final.isRejected).toEventually(beTrue())
    }

}
