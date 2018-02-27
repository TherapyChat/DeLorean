//
//  Promise+Errors.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

/// Typed errors for explicit reject cases
enum Break: Error {
    case async
    case validate
    case timeout
}
