//
//  PromiseRecoverTests.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import XCTest
import Nimble
import DeLorean

final class PromiseRecoverTests: XCTestCase {

    func testRecover() {
        let promise = Promise<Int> { _, _, reject, _ in
            reject(SimpleError())
        }.recover { error in
            expect(error as? SimpleError).to(equal(SimpleError()))
            return Promise { future in
                future(.fulfill(5))
            }
        }

        expect(promise.value).toEventually(equal(5))
        expect(promise.isFulfilled).toEventually(beTrue())
    }


    func testRecoverWithThrowingFunction() {
        let promise = Promise<Int> { _ in
            throw SimpleError()
        }.recover { error in
            expect(error as? SimpleError).to(equal(SimpleError()))
            _ = try JSONSerialization.data(withJSONObject: ["key": "value"], options: [])
            return Promise { future in
                future(.fulfill(5))
            }
        }

        expect(promise.value).toEventually(equal(5))
        expect(promise.isFulfilled).toEventually(beTrue())
    }


    func testRecoverWithThrowingFunctionError() {
        let promise = Promise<Int> { _, _, reject, _ in
            delay(0.1) { reject(SimpleError()) }
        }.recover { (error) -> Promise<Int> in
            let mock = Mock()
            try mock.throw()
            return Promise(value: 2)
        }.catch { error in
            expect(error as? SimpleError).to(equal(SimpleError()))
        }

        expect(promise.isRejected).toEventually(beTrue())
    }

    func testRecoverInstant() {
        let promise = Promise<Int>(error: SimpleError())
            .recover({ error in
                expect(error as? SimpleError).to(equal(SimpleError()))
                return Promise(resolvers: { _, fulfill, _, _ in
                    fulfill(5)
                })
            })

        expect(promise.value).toEventually(equal(5))
        expect(promise.isFulfilled).toEventually(beTrue())
    }

    func testIgnoreRecover() {
        let promise = Promise<Int> { future in
            future(.fulfill(2))
        }.recover { error in
            expect(error as? SimpleError).to(equal(SimpleError()))
            return Promise { future in
                future(.fulfill(5))
            }
        }

        expect(promise.value).toEventually(equal(2))
        expect(promise.isFulfilled).toEventually(beTrue())
    }

    func testIgnoreRecoverInstant() {

        let promise = Promise(value: 2)
            .recover({ error in
                expect(error as? SimpleError).to(equal(SimpleError()))
                return Promise { _, fulfill, _, _ in
                    fulfill(5)
                }
            })

        expect(promise.value).toEventually(equal(2))
        expect(promise.isFulfilled).toEventually(beTrue())
    }
}
