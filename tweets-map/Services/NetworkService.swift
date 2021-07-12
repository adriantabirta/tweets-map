//
//  NetworkService.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 08.07.2021.
//

import Foundation

struct EmptyBody: Codable {}

enum ServiceMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol NetworkService: CustomStringConvertible {
    
    /// http headers like authorization, content-type...
    ///
    var headers: [String: Any] { get }
    
    /// Base url.
    ///
    var baseURL: String { get }
    
    /// Path from base url
    ///
    var path: String { get }
    
    /// Http method.
    ///
    var method: ServiceMethod { get }
    
    /// Query parameters
    ///
    var parameters: [String: Any] { get }
    
    /// Body
    ///
    var body: Data? { get }
}

extension NetworkService {
    
    private var url: URL? {
        return URL(string: baseURL + path)
    }
    
    public var urlRequest: URLRequest {
        guard let url = self.url else { fatalError("URL could not be built") }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = method.rawValue
        if !headers.isEmpty {
            headers.forEach { (key, value) in
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        if (method == .post) {
            print("make body: \(String(data: body!, encoding: .utf8) ?? "")")
            request.httpBody = body!
        }
        
        return request
    }
    
    var description: String {
        return "Request: \(method.rawValue) \(url?.absoluteString ?? "") \(body?.description ?? "")"
    }
}

extension NetworkService {
    
    var parameters: [String: Any] {
        return [:]
    }
}
