//
//  Promise+Recover.swift
//  DeLorean
//
//  Created by sergio on 23/10/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

extension Promise {

    /**
     ### Recover
     This function lets us catch an error and easily recover from it without breaking the rest of the promise chain.

     ```swift
     let foobar = Promise<Int> { _ in
        throw SimpleError()
     }.recover { error in
        return Promise(value: 0)
     }.then {
        print($0)
     }.catch {
        // Handle error
     }
     ```
     */
    @discardableResult
    public func recover(_ recovery: @escaping (Error) throws -> Promise<T>) -> Promise<T> {
        return Promise(resolvers: { _, fulfill, reject, _ in
            self.then(fulfill).catch({ error in
                do {
                    try recovery(error).then(fulfill, reject)
                } catch let error {
                    reject(error)
                }
            })
        })
    }

}
