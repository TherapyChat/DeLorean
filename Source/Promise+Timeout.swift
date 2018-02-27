//
//  Promise+Timeout.swift
//  DeLorean
//
//  Created by sergio on 23/10/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

extension Promise {

    /**
     ### Timeout

     Timeout allows us to wait for a promise for a time interval or reject it, if it doesn't resolve within the
     given  time. The interval is expresed in seconds.

     ```swift
     let promise = Promise<Int> { future in
         future(.fulfill(5))
         }.timeout(0.5)
     ```
    */
    @discardableResult
    public func timeout(_ timeout: TimeInterval) -> Promise<T> {
        return Promise.race([self, Promise.timeout(timeout)])
    }

    /**
     ### Timeout

     Static implementation for timeout. The interval is expresed in seconds.

     ```swift
     Promise<Void>.timeout(0.2).then {
        // do something
     }
     ```
     */
    @discardableResult
    public static func timeout<T>(_ timeout: TimeInterval) -> Promise<T> {
        return Promise<T> { future in
            delay(timeout).then { _ in
                future(.reject(Break.timeout))
            }
        }
    }

    /**
     ### Delay

     Defer the execution of a Promise by a given time interval.

     ```swift
     let promise = Promise<Void>.delay(0.2).then {
        // do something
     }
     ```
     */
    @discardableResult
    public static func delay(_ delay: TimeInterval) -> Promise<Void> {
        return Promise<Void> { future in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                future(.fulfill(()))
            })
        }
    }
}
