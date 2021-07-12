//
//  AppError.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 09.07.2021.
//

import UIKit

enum AppError: Error, CustomStringConvertible {
    case api
    case network(Int, String)
    case unableToDecode
    case unknown
    
    init?(_ error: Error) {
        switch error.localizedDescription {
        // todo: handle here all catched errors
        default:
            self = .unknown
        }
    }
    
    var description: String {
        switch self {
        case .api:
            return self.description
        case let .network(code, error):
            return "\(code) - \(error)"
        case .unableToDecode, .unknown:
            return "Something bad happend."
        }
    }
}

extension AppError {
    
    func handle() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Oops!", message: self.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        }
    }
}
