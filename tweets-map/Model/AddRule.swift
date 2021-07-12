//
//  AddRule.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 12.07.2021.
//

import Foundation

struct AddRule: Encodable {
    
    struct RuleValue: Encodable {
        var value: String
    }
    
    var add: [RuleValue]
}
