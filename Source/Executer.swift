//
//  Queue+Extended.swift
//  DeLorean
//
//  Created by sergio on 23/10/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

/// Interface for task work item
public protocol Executer {

    /// Task work item
    func execute(_ work: @escaping () -> Void)
}

/// All threads extends executer protocol
extension DispatchQueue: Executer {

    /// Execute async task on this thread
    public func execute(_ work: @escaping () -> Void) {
        self.async(execute: work)
    }

}
