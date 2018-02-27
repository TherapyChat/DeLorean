//
//  Promise+Catch.swift
//  DeLorean
//
//  Created by sergio on 22/02/2018.
//  Copyright © 2018 nc43tech. All rights reserved.
//

import Foundation

extension Promise {

    /**
     ### Catch

     This function allows you to handle Promise's errors. The operator itself implicitly returns another promise,
     that is rejected with the same error.

     ```swift
     let foobar = Promise<Void> { future in
        future(.reject(SimpleError()))
     }.then({ value in
        print(value)
     }).catch({ error in
        // Handle simple error here
     })
     ```
    */
    @discardableResult
    public func `catch`(on queue: Executer = DispatchQueue.main,
                        _ rejected: @escaping (Error) -> Void) -> Promise<T> {
        return then(on: queue, { _ in }, rejected)
    }

}
