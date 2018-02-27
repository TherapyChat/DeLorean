//
//  Promise+Always.swift
//  DeLorean
//
//  Created by sergio on 23/10/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

extension Promise {

    /**
     ### Always

     This function allows you to specify a block which will be always executed both for fulfill and reject the Promise.

     ```swift
     let foobar = Promise<Int> { _ in
     	throw SimpleError()
     }.then {
        print($0)
     }.catch {
        // Handle error
     }.always {
        // This block is always called
     }
     ```
     */
    @discardableResult
    public func always(on context: Executer = DispatchQueue.main,
                       _ completion: @escaping () -> Void) -> Promise<T> {
        return then(on: context, { _ in completion() }, { _ in completion() })
    }

}
