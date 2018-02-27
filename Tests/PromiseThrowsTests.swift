//
//  PromiseThrowsTests.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import XCTest
import Nimble
import DeLorean

final class PromiseThrowsTests: XCTestCase {

    func testThrowsInMapping() {

        let promise = Promise(value: 2)
            .then { value -> Int in
                guard value != 3 else { throw SimpleError() }
                return 5
        }

        expect(promise.value).toEventually(equal(5))
    }
    
    func testThrowsInMappingWithError() {

        let promise = Promise(value: 2)
            .then { value -> Int in
                guard value != 2 else { throw SimpleError() }
                return 5
        }

        expect(promise.error is SimpleError).toEventually(beTrue())
    }
    
    func testThrowsInFlatmapping() {

        let promise = Promise(value: 2)
            .then { value -> Promise<Int> in
                guard value != 3 else { throw SimpleError() }
                return Promise(value: 5)
        }

        expect(promise.value).toEventually(equal(5))
    }
    
    func testThrowsInFlatmappingWithError() {

        let promise = Promise(value: 2)
            .then { value -> Promise<Int> in
                guard value != 2 else { throw SimpleError() }
                return Promise(value: 5)
        }

        expect(promise.error is SimpleError).toEventually(beTrue())
    }

}
