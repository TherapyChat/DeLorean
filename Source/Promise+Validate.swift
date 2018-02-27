//
//  Promise+Validate.swift
//  DeLorean
//
//  Created by sergio on 23/10/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

extension Promise {

    /**
     ### Validate

     Validate is a function that takes a predicate, and rejects the promise chain if that predicate fails.

     ```swift
     let promise = Promise(value: 2)
         .validate { $0 == 3 }
         .catch { error in
             // This promise always fails
     }
     ```
    */
    @discardableResult
    public func validate(_ predicate: @escaping (T) -> Bool) -> Promise<T> {
        return then({ (value: T) -> T in
            guard predicate(value) else { throw Break.validate }
            return value
        })
    }

}
