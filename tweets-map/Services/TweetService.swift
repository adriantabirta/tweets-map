//
//  TweetService.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 08.07.2021.
//

import UIKit

enum TweetService: NetworkService {
    case findAllRules
    case addRule(query: String)
    case removeAllRules(ids: [String])
    case streamTweets
}

extension TweetService {
    
    var headers: [String : Any] {
        return [:]
//        return [ "Content-Type": "application/json",
//                 "Authorization": "Bearer AAAAAAAAAAAAAAAAAAAAADLURQEAAAAA1I%2BD0wmx4tcAUwC0VgDzl2yrzT4%3DRV7ee30R1IL3wQJ3Sq41YRV1xPd6ax5m64MZsItMly4m86jHKu"]
    }
    
    var method: ServiceMethod {
        switch self {
        case .findAllRules, .streamTweets:
            return .get
        case .addRule(_), .removeAllRules(_):
            return .post
        }
    }
    
    var path: String {
//        switch self {
//        case .findAllRules, .addRule(_), .removeAllRules(_):
//            return "/tweets/search/stream/rules"
//
//        case .streamTweets:
//            return "/tweets/search/stream?tweet.fields=created_at,geo&expansions=author_id&user.fields=created_at"
//        }
        return ""
    }
    
    var baseURL: String {
        // return "https://api.twitter.com/2"
//        return "http://localhost:8080"
        return "http://192.168.100.28:8080"
    }
    
    var body: Data? {
        switch self {
        case let .addRule(query):
            return encode(object: AddRule.init(add: [AddRule.RuleValue(value: query)]))
        case let .removeAllRules(ids):
            return encode(object: RemoveRule(delete: .init(ids: ids)))
        default:
            return nil
        }
    }
    
    private func encode<E: Encodable>(object: E) -> Data? {
        do {
            return try JSONEncoder().encode(object)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
