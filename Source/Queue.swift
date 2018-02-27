//
//  Queue.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

/// Invalidatable queues for work with Promises
public final class Queue {

    private var valid = true
    private let queue: DispatchQueue

    /// Constructor for invalidatable queue
    public init(queue: DispatchQueue = .main) {
        self.queue = queue
    }

    /// Invalidate current queue
    public func invalidate() {
        valid = false
    }

}

extension Queue: Executer {

    /// Dispatch work item on valid queue
    public func execute(_ work: @escaping () -> Void) {
        guard valid else { return }
        queue.async(execute: work)
    }
    
}
