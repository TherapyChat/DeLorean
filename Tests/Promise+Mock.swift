//
//  delay.swift
//  DeLorean
//
//  Created by sergio on 10/05/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import XCTest

struct Mock {

    func `throw`() throws {
        throw SimpleError()
    }
}
