//
//  Future.swift
//  DeLorean
//
//  Created by sergio on 13/02/2018.
//  Copyright © 2018 nc43tech. All rights reserved.
//

import Foundation

/// States for Promise
public enum Future<T> {
    /// Promise is in progress
    case progress(T)
    /// Promise is successful fulfill
    case fulfill(T)
    /// Promise is break
    case reject(Error)
    /// Promise is cancelled
    case cancel
}
