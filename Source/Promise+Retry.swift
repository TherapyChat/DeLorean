//
//  Promise+Retry.swift
//  DeLorean
//
//  Created by sergio on 23/10/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

extension Promise {

    /**
    ### Retry

     Retry operator allows you to execute source chained promise if it ends with a rejection.
     If reached the attempts the promise still rejected chained promise is also rejected along with the same
     source error.

     ```swift
     let promise = Promise<Int>
         .retry(attempt: 3) { () -> Promise<Int> in
             guard threshold != 1 else { return Promise(value: 8) }
             threshold -= 1
             return Promise(error: SimpleError())
     }
    ```
    */
    @discardableResult
    public static func retry<T>(attempt: Int,
                                delay: TimeInterval = 0,
                                generate: @escaping () -> Promise<T>) -> Promise<T> {
        guard attempt > 1 else { return generate() }
        return Promise<T>(resolvers: { _, fulfill, reject, _ in
            generate().recover({ _ in
                return self.delay(delay).then({
                    return retry(attempt: attempt-1, delay: delay, generate: generate)
                })
            }).then(fulfill).catch(reject)
        })
    }

}
