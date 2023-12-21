//
//  Observable.swift
//  CaveTickers
//
//  Created by 1 on 2023/12/17.
//

import Foundation

class Observable<T> {
    var value: T {
        didSet {
            onChange?(value)
        }
    }

    var onChange: ((T) -> Void)?
    var onCompleted: (() -> Void)?

    init(_ value: T) {
        self.value = value
    }

    func bind(onChange: @escaping (T) -> Void, onCompleted: (() -> Void)? = nil) {
        self.onChange = onChange
        self.onCompleted = onCompleted
//        onChange(value)
    }
}
