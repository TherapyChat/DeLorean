//
//  Promise.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

/**
 ## Overview

 DeLorean is a lightweight framework which allows you to write better async code in Swift.
 We designed DeLorean to be simple to use and also very flexible.
 It's partially based on [JavaScript A+](https://promisesaplus.com) specs.
 We have added some useful features like `progressable` and `cancellable` promises.
 This promises layer queues all async task on background to avoid block the main thread.

*/
public final class Promise<T> {

    private let mutex: Mutex = Mutex()
    private var state: State<T> = .pending
    private var callbacks: [Callback<T>] = []

    /// Creates an instant pending Promise
    public init() {}

    /// Creates an instant fulfilled Promise
    public init(value: T) {
        state = .fulfilled(value)
    }

    /// Creates an instant rejected Promise
    public init(error: Error) {
        state = .rejected(error)
    }

    /**
     Creates a Promise with block-based api

     - parameter resolvers:   Multiples blocks to handle the future state of promise

     - returns: The new `Promise` instance.
     */
    @discardableResult
    public init(context: Executer = DispatchQueue.global(qos: .userInitiated),
                resolvers: @escaping
        (
        _ progress: @escaping(T) -> Void,
        _ fulfill: @escaping (T) -> Void,
        _ reject: @escaping (Error) -> Void,
        _ cancelled: @escaping () -> Void) throws -> Void) {
        context.execute {
            do {
                try resolvers(self.progress, self.fulfill, self.reject, self.cancel)
            } catch let error {
                self.reject(error)
            }
        }
    }

    /**
     Creates a Promise with enum-based DSL

     - parameter future:   Future value-type to handle the future state of promise

     - returns: The new `Promise` instance.
     */
    @discardableResult
    public init(context: Executer = DispatchQueue.global(qos: .userInitiated),
                future: @escaping ( @escaping (Future<T>) -> Void) throws -> Void) {
        context.execute {
            do {
                try future(self.resolve)
            } catch let error {
                self.reject(error)
            }
        }
    }

    /**
    ### Progress

    If there is an asynchronous action that can "succeed" more than once, or delivers a series of values over time
     instead of just one, but you don't want to finish the promise you can use this function.

    ```swift
    let foobar = Promise<Int> { future in
        future(.progress(0))
        future(.progress(1))
        future(.progress(2))
        future(.fulfill(3))
        }.progress({ value in
            // This block is called multiple times
            print(value)
        }).then({ value in
            // This block is called once
            print(value)
        })
    ```
    */
    @discardableResult
    public func progress(on context: Executer = DispatchQueue.main,
                         _ progressed: @escaping (T) -> Void) -> Promise<T> {
        return Promise<T> { progress, fulfill, reject, cancel in
            self.callback(on: context,
                          progressed: { value in
                            progress(value)
                            progressed(value)
            }, fulfilled: fulfill,
               rejected: reject,
               cancelled: cancel)
        }
    }

    /// Map for chaineable promises
    @discardableResult
    public func then<U>(on context: Executer = DispatchQueue.main,
                        _ transform: @escaping (T) throws -> Promise<U>) -> Promise<U> {
        return Promise<U>(resolvers: { _, fulfill, reject, cancel in
            self.callback(
                on: context,
                progressed: { _ in },
                fulfilled: { value in
                    do {
                        try transform(value).then(fulfill, reject)
                    } catch let error {
                        reject(error)
                    }
            },
                rejected: reject,
                cancelled: cancel
            )
        })
    }

    /// FlatMap for chaineable promises
    @discardableResult
    public func then<U>(on context: Executer = DispatchQueue.main,
                        _ transform: @escaping (T) throws -> U) -> Promise<U> {
        return then(on: context, { value -> Promise<U> in
            do {
                return Promise<U>(value: try transform(value))
            } catch let error { return Promise<U>(error: error) } })
    }

    /**
    ### Then

    You can simple chaining multiple asynchronous tasks.

    ```swift
    let foobar = Promise { future in
        future(.fulfill("foobar"))
    }

    promise.then { value in
        print(value)
    }
    ```
    */
    @discardableResult
    public func then(on context: Executer = DispatchQueue.main,
                     _ fulfilled: @escaping (T) -> Void,
                     _ rejected: @escaping (Error) -> Void = { _ in },
                     _ progressed: @escaping (T) -> Void = { _ in },
                     _ cancelled: @escaping () -> Void = { }) -> Promise<T> {
        callback (on: context,
            progressed: progressed,
            fulfilled: fulfilled,
            rejected: rejected,
            cancelled: cancelled)
        return self
    }

    /**
    ### Cancel

    This function will trigger a callback that the promise can use to cancel its work. Naturally,
     requesting cancellation of a promise that has already been resolved does nothing,
     even if the callbacks have not yet been invoked.

    ```swift
    let foobar = Promise<Int> { future in
        future(.progress(0))
        future(.cancel)
        future(.fulfill(3))
        }.progress {
            print($0)
        }.cancel {
            // Handle cancellable work
        }.then { value in
            // This block is never called
            print(value)
    }
    ```
    */
    @discardableResult
    public func cancel(on context: Executer = DispatchQueue.main,
                       _ cancelled: @escaping () -> Void) -> Promise<T> {
        return Promise<T> { progress, fulfill, reject, cancel in
            self.callback(on: context,
                          progressed: progress,
                          fulfilled: fulfill,
                          rejected: reject,
                          cancelled: {
                            cancel()
                            cancelled()
            })
        }
    }

    /// Returns if promise state is pending
    public var isPending: Bool {
        return !isFulfilled && !isRejected && !isCancelled
    }

    /// Returns if promise state is fulfilled
    public var isFulfilled: Bool {
        return value != nil
    }

    /// Returns if promise state is rejected
    public var isRejected: Bool {
        return error != nil
    }

    /// Returns if promise state is cancelled
    public var isCancelled: Bool {
        return state.isCancelled
    }

    /// Returns current value of promise
    public var value: T? {
        return mutex.synchronized {
            return self.state.value
        }
    }

    /// Returns current error of promise
    public var error: Error? {
        return mutex.synchronized {
            return self.state.error
        }
    }

    /// Update promise state synchronous to progressed
    public func progress(_ value: T) {
        update(state: .progressed(value))
    }

    /// Update promise state synchronous to fulfilled
    public func fulfill(_ value: T) {
        update(state: .fulfilled(value))
    }

    /// Update promise state synchronous to rejected
    public func reject(_ error: Error) {
        update(state: .rejected(error))
    }

    /// Update promise state synchronous to cancelled
    public func cancel() {
        update(state: .cancel)
    }

    private func resolve(_ future: Future<T>) {
        switch future {
        case .progress(let value):
            progress(value)
        case .fulfill(let value):
            fulfill(value)
        case .reject(let error):
            reject(error)
        case .cancel:
            cancel()
        }
    }

    private func update(state: State<T>) {
        guard isPending else { return }
        mutex.lock { self.state = state }
        execute()
    }

    private func callback(on context: Executer = DispatchQueue.main,
                          progressed: @escaping (T) -> Void,
                          fulfilled: @escaping (T) -> Void,
                          rejected: @escaping (Error) -> Void,
                          cancelled: @escaping () -> Void) {
        let callback = Callback(context: context,
                                progressed: progressed,
                                fulfilled: fulfilled,
                                rejected: rejected,
                                cancelled: cancelled)
        mutex.lock { self.callbacks.append(callback) }
        execute()
    }

    private func execute() {
        mutex.lock {
            self.callbacks.forEach { callback in
                switch self.state {
                case .pending: break
                case let .progressed(value):
                    callback.progress(value)
                case let .fulfilled(value):
                    callback.fulfill(value)
                    self.callbacks.removeAll()
                case let .rejected(error):
                    callback.reject(error)
                    self.callbacks.removeAll()
                case .cancel:
                    callback.cancel()
                    self.callbacks.removeAll()
                }
            }
        }
    }
}
