//
//  QueueTests.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import XCTest
import Nimble
import DeLorean

final class QueueTests: XCTestCase {

    func testNonInvalidatedInvalidatableQueue() {

        let invalidatableQueue = Queue()
        let promise = Promise(value: 5)
            .then(on: invalidatableQueue, { _ in
        })

        expect(promise.value).toEventually(equal(5))
    }

    func testInvalidatedInvalidatableQueue() {

        let invalidatableQueue = Queue()

        invalidatableQueue.invalidate()

        let promise = Promise(value: 5)
            .then(on: invalidatableQueue, { _ in
                fail()
        })

        expect(promise.value).toEventually(equal(5))
    }

    func testTapContinuesToFireInvalidatableQueue() {

        let invalidatableQueue = Queue()
        invalidatableQueue.invalidate()

        let promise = Promise(value: 5)
            .then(on: invalidatableQueue, { (_) -> Void in
                dispatchPrecondition(condition: .onQueue(.main))
                fail()
            })

        expect(promise.value).toEventually(equal(5))
    }

    func testInvalidatableQueueSupportsNonMainQueues() {

        let backgroundQueue = DispatchQueue(label: "testqueue")
        let invalidatableQueue = Queue(queue: backgroundQueue)

        let promise = Promise(value: 5)
            .then(on: invalidatableQueue, { (_) -> Void in
                dispatchPrecondition(condition: .notOnQueue(.main))
            })

        expect(promise.value).toEventually(equal(5))
    }
    
}
