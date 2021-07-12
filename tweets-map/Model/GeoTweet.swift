//
//  GeoTweet.swift
//  tweets-map
//
//  Created by Tabirta Adrian on 09.07.2021.
//

import MapKit

let tweetLifespan = TimeInterval(30) // sec

class GeoTweet: NSObject, Decodable {
    
    fileprivate(set) var id: String
    
    private var text: String
    
    var latitude: Double?
    
    var longitude: Double?
    
    var createdAt: Date
    
    var expireAt = Date().addingTimeInterval(tweetLifespan)
    
    enum CodingKeys: String, CodingKey {
        case data, id, text, created_at, geo, coordinates
    }
    
    required init(from decoder: Decoder) throws {
        
        let baseContainer = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try baseContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        id = try dataContainer.decode(String.self, forKey: .id)
        text = try dataContainer.decode(String.self, forKey: .text)
        createdAt = try dataContainer.decode(Date.self, forKey: .created_at)
               
        let geoContainer = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .geo)
        
        let coordinatesContainer = try? geoContainer.nestedContainer(keyedBy:  CodingKeys.self, forKey: .coordinates)
        guard let unwrappedCoordinatesContainer = coordinatesContainer else { return }
        
        let coordinatesArray = try unwrappedCoordinatesContainer.decodeIfPresent([Double].self, forKey: .coordinates)
        
        latitude = coordinatesArray?.last
        longitude = coordinatesArray?.first
    }
    
    override var description: String {
        return "GeoTweet{id: \(id), title: \(String(describing: title ?? "")), coordinate: \(coordinate), createdAt: \(createdAt) }"
    }
}

extension GeoTweet: MKAnnotation {
    
    var title: String? {
        return text
    }
    
    var subtitle: String? {
        return nil
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)
    }
    
    var containsCoordinates: Bool {
        return latitude != nil && longitude != nil
    }
}
