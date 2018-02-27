//
//  Promise+All.swift
//  DeLorean
//
//  Created by sergio on 23/10/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

extension Promise {

    /**
    ### All

     This function create a Promise that resolved when the list of passed Promises resolves (promises are resolved in
     parallel). Promise also reject as soon as a promise reject for any reason.

     ```
     let promise1 = Promise(value: 1)
     let promise2 = Promise(value: 2)
     let promise3 = Promise(value: 3)
     let promise4 = Promise(value: 4)

     let promise = Promise<Int>
         .all([promise1, promise2, promise3, promise4])
         .then { values in
             for number in values {
                 print(number)
             }
     }
    ```
     */
    @discardableResult
    public static func all<T>(_ promises: [Promise<T>]) -> Promise<[T]> {
        return Promise<[T]>(future: { future in
            guard !promises.isEmpty else { return future(.fulfill([])) }
            for promise in promises {
                promise.then({ value in
                    if !promises.contains(where: { $0.isRejected || $0.isPending }) {
                        future(.fulfill(promises.compactMap({ $0.value })))
                    }
                }).catch({ error in
                    future(.reject(error))
                })
            }
        })
    }
}
