//: Playground - noun: a place where people can play

import PlaygroundSupport
import Foundation
import DeLorean

PlaygroundPage.current.needsIndefiniteExecution = true

let foobar = Promise { future in
    future(.fulfill("foobar"))
}

foobar.then { test in
    print(test)
}
