//
//  Promise+Zip.swift
//  DeLorean
//
//  Created by sergio on 23/10/2017.
//  Copyright © 2017 nc43tech. All rights reserved.
//

import Foundation

extension Promise {

    /**
    ### Zip

     This function allows you to join different promises 2 and return a tuple with the result of them.
     Promises are resolved in parallel.

     ```swift
     let promise1 = Promise(value: 0)
     let promise2 = Promise(value: "foobar")
     let zipped = Promise<Void>.zip(promise1, promise2)
         .then { value1, value2 in
             print(value1) // This function prints `0`
             print(value2) // This function prints `"foobar"`
    }
    ```
    */
    @discardableResult
    public static func zip<T, U>(_ first: Promise<T>,
                                 _ second: Promise<U>) -> Promise<(T, U)> {
        return Promise<(T, U)>(resolvers: { _, fulfill, reject, _ in
            let resolver: (Any) -> Void = { _ in
                if let firstValue = first.value, let secondValue = second.value {
                    fulfill((firstValue, secondValue))
                }
            }
            first.then(resolver, reject)
            second.then(resolver, reject)
        })
    }

    /**
     ### Zip

     This function allows you to join different promises 3 and return a tuple with the result of them.
     Promises are resolved in parallel.

     ```swift
     let promise1 = Promise(value: 0)
     let promise2 = Promise(value: "foo")
     let promise3 = Promise(value: "bar")
     let zipped = Promise<Void>.zip(promise1, promise2, promise3)
        .then { value1, value2, value3 in
            print(value1) // This function prints `0`
            print(value2) // This function prints `"foo"`
            print(value3) // This function prints `"bar"`
     }
     ```
     */
    @discardableResult
    public static func zip<T1, T2, T3>(_ first: Promise<T1>,
                                       _ second: Promise<T2>,
                                       _ last: Promise<T3>) -> Promise<(T1, T2, T3)> {
        return Promise<(T1, T2, T3)>(resolvers: { (_, fulfill: @escaping ((T1, T2, T3)) -> Void, reject: @escaping (Error) -> Void, _) in // swiftlint:disable:this line_length
            let zipped: Promise<(T1, T2)> = zip(first, second)

            func resolver() {
                if let zippedValue = zipped.value, let lastValue = last.value {
                    fulfill((zippedValue.0, zippedValue.1, lastValue))
                }
            }
            zipped.then({ _ in resolver() }, reject)
            last.then({ _ in resolver() }, reject)
        })
    }

    /**
    ### Zip

     This function allows you to join different promises 4 and return a tuple with the result of them.
     Promises are resolved in parallel.

     ```swift
     let promise1 = Promise(value: 0)
     let promise2 = Promise(value: "foo")
     let promise3 = Promise(value: "bar")
     let promise4 = Promise(value: true)
     let zipped = Promise<Void>.zip(promise1, promise2, promise3, promise4)
            .then { value1, value2, value3 in
                print(value1) // This function prints `0`
                print(value2) // This function prints `"foo"`
                print(value3) // This function prints `"bar"`
                print(value4) // This function prints `true`
     }
    ```
    */
    @discardableResult
    public static func zip<T1, T2, T3, T4>(_ first: Promise<T1>,
                                           _ second: Promise<T2>,
                                           _ third: Promise<T3>,
                                           _ last: Promise<T4>) -> Promise<(T1, T2, T3, T4)> {
        return Promise<(T1, T2, T3, T4)>(resolvers: { (_, fulfill: @escaping ((T1, T2, T3, T4)) -> Void, reject: @escaping (Error) -> Void, _) in // swiftlint:disable:this line_length
            let zipped: Promise<(T1, T2, T3)> = zip(first, second, third)

            func resolver() {
                if let zippedValue = zipped.value, let lastValue = last.value {
                    fulfill((zippedValue.0, zippedValue.1, zippedValue.2, lastValue))
                }
            }
            zipped.then({ _ in resolver() }, reject)
            last.then({ _ in resolver() }, reject)
        })
    }

}
