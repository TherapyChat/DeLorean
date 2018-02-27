//
//  Promise+Error.swift
//  DeLorean
//
//  Created by sergio on 23/02/2018.
//  Copyright © 2018 nc43tech. All rights reserved.
//

import Foundation

struct SimpleError: Error { }

extension SimpleError: Equatable {

    public static func ==(lhs: SimpleError, rhs: SimpleError) -> Bool {
        return true
    }
}
