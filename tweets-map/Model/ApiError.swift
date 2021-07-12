//
//  ApiError.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 09.07.2021.
//

import UIKit

enum ApiError: Error, CustomStringConvertible {
    
    /// Errors with status code `400` that should be handled and maybe show to user.
    case generalError(code: Int, message: String)
    
    /// Smth bad happend on the way
    case unknown
    
    /// All error `!=400`. Not displayed to user.
    case protocolError
    
    init?(_ error: Error) {
        switch error.localizedDescription {
        // todo: handle here all catched errors
        default:
            self = .protocolError
        }
    }
    
    var description: String {
        
        switch self {
        case .generalError(let code, let message):
            return "ApiError(code:\(code), message: \(message))"
            
        case .unknown:
            return "ApiError - Something bad happend."
            
        case .protocolError:
            return "ApiError.protocolError - should be handled by system"
        }
    }
}
