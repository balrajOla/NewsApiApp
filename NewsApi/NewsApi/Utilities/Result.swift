//
//  Result.swift
//  flickrApp
//
//  Created by Balraj Singh on 09/12/18.
//  Copyright © 2018 balraj. All rights reserved.
//

import Foundation

struct CustomError: Error, Decodable {
    var message: String
}

public enum Res<A, CustomError> {
    case success(A)
    case failure(ServiceError<CustomError>)
}

extension Res {
    init(value: A?, or error: ServiceError<CustomError>) {
        guard let value = value else {
            self = .failure(error)
            return
        }
        
        self = .success(value)
    }
    
    var value: A? {
        guard case let .success(value) = self else { return nil }
        return value
    }
    
    var error: ServiceError<CustomError>? {
        guard case let .failure(error) = self else { return nil }
        return error
    }
}


extension Res {
    func flatMap<U>(_ transform: (A) -> Res<U, CustomError>) -> Res<U, CustomError> {
        switch self {
        case .success(let val): return transform(val)
        case .failure(let e): return .failure(e)
        }
    }
    
    func map<U>(_ transform: (A) -> U) -> Res<U, CustomError> {
        switch self {
        case .success(let val): return .success(transform(val))
        case .failure(let e): return .failure(e)
        }
    }
}
