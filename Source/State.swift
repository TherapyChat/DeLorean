//
//  State.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

enum State<T> {
    case pending
    case progressed(T)
    case fulfilled(T)
    case rejected(Error)
    case cancel
}

extension State {

    var isCancelled: Bool {
        if case .cancel = self {
            return true
        }
        return false
    }

    var value: T? {
        if case let .fulfilled(value) = self {
            return value
        }
        return nil
    }

    var error: Error? {
        if case let .rejected(error) = self {
            return error
        }
        return nil
    }

}
