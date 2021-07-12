//
//  TwitterResponse.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 12.07.2021.
//

import UIKit

struct TwitterResponse<D: Decodable>: Decodable {

    enum CodingKeys: String, CodingKey {
        case data
    }
    
    var data: D?
    
    init(from decoder: Decoder) throws {
        let baseContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try baseContainer.decodeIfPresent(D.self, forKey: .data)
    }
}
