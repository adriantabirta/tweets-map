//
//  RemoveRule.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 12.07.2021.
//

import Foundation

struct RemoveRule: Encodable {
  
    struct Delete: Encodable {
        var ids: [String]
    }
    
    var delete: Delete
}
