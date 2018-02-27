//
//  Callback.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

struct Callback<T> {

    private let _progressed: (T) -> Void
    private let _fulfilled: (T) -> Void
    private let _rejected: (Error) -> Void
    private let _cancelled: () -> Void
    private let _context: Executer

    init(context: Executer,
         progressed: @escaping (T) -> Void,
         fulfilled: @escaping (T) -> Void,
         rejected: @escaping (Error) -> Void,
         cancelled: @escaping () -> Void) {
        _progressed = progressed
        _fulfilled = fulfilled
        _rejected = rejected
        _cancelled = cancelled
        _context = context
    }

    func progress(_ value: T) {
        _context.execute {
            self._progressed(value)
        }
    }

    func fulfill(_ value: T) {
        _context.execute {
            self._fulfilled(value)
        }
    }

    func reject(_ error: Error) {
        _context.execute {
            self._rejected(error)
        }
    }

    func cancel() {
        _context.execute {
            self._cancelled()
        }
    }
}
