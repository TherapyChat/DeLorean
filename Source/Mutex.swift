//
//  Mutex.swift
//  DeLorean
//
//  Created by sergio on 14/02/2018.
//  Copyright © 2018 nc43tech. All rights reserved.
//

import Foundation

final class Mutex {

    private var mutex = pthread_mutex_t()

    init() {
        pthread_mutex_init(&mutex, nil)
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    @discardableResult
    func lock() -> Int32 {
        return pthread_mutex_lock(&mutex)
    }

    @discardableResult
    func unlock() -> Int32 {
        return pthread_mutex_unlock(&mutex)
    }

    func lock(execute work: () -> Void) {
        let status = lock()
        assert(status == 0, "pthread_mutex_lock: \(strerror(status))")
        defer { unlock() }
        work()
    }

    func synchronized<T>(execute work: () -> T) -> T {
        let status = lock()
        assert(status == 0, "pthread_mutex_lock: \(strerror(status))")
        defer { unlock() }
        return work()
    }
}
