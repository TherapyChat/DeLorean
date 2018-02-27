//
//  Promise+Delay.swift
//  DeLorean
//
//  Created by sergio on 23/02/2018.
//  Copyright © 2018 nc43tech. All rights reserved.
//

import Foundation

internal func delay(_ duration: TimeInterval, block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
        block()
    })
}
