//
//  Promise+Race.swift
//  DeLorean
//
//  Created by sergio on 23/10/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

extension Promise {

    /**
     ### Race
     This function race many asynchronous promises and return the value of the first to complete.

     ```swift
     let promise1 = Promise(value: 1)
     let promise2 = Promise(value: 2)
     let promise3 = Promise(value: 3)
     let promise4 = Promise(value: 4)

     let promise = Promise<Int>
        .race([promise1, promise2, promise3, promise4])
        .then { fastValue in
            print(fastValue)
     }
     ```
     */
    @discardableResult
    public static func race<T>(on context: Executer = DispatchQueue.main, _ promises: [Promise<T>]) -> Promise<T> {
        return Promise<T>(resolvers: { _, fulfill, reject, _ in
            for promise in promises {
                promise.then(on: context, fulfill, reject)
            }
        })
    }
}
