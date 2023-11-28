//
//  FetchPhase.swift
//  CaveTickers
//
//  Created by 1 on 2023/11/23.
//

import Foundation

enum FetchPhase<V> {

    case initial
    case fetching
    case success(V)
    case failure(Error)
    case empty

    var value: V? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }

    var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }

}
