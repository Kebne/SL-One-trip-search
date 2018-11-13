//
//  Station.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

enum StationJourneyType {
    case start, destination
}

enum StationDecodingError : Error {
    case errorCreatingCoordinates
}

struct Station : Codable {
    let name: String
    let area: String
    let id: String
    let lat: Double
    let long: Double
}

struct SLStation {
    let name: String
    let id: String
    let x: String
    let y: String
    var station: Station {
        return constructStation()
    }
    
    private func constructStation() ->Station {
        var longString = x
        var latString = y
        var latitude = 0.0
        var longitude = 0.0
        let nameAndArea = name.separateParenthesisString()
   
        longString.insert(".", at: longString.index(longString.startIndex, offsetBy: 2))
        latString.insert(".", at: longString.index(longString.startIndex, offsetBy: 2))
        
        if let long = Double(longString), let lat = Double(latString) {
            latitude = lat
            longitude = long
        }
 
        return Station(name: nameAndArea.string, area: nameAndArea.inParentheses, id: id, lat: latitude, long: longitude)
    }
}

struct StationSearchResult : Decodable {
    let values: [SLStation]
    enum StationCodingResultKey : String, CodingKey {
        case values = "ResponseData"
    
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StationCodingResultKey.self)
        values = try container.decode([SLStation].self, forKey: .values)
        
    }
}

extension SLStation : Decodable {
    enum StationKey : String, CodingKey {
        case name = "Name"
        case id = "SiteId"
        case x = "X"
        case y = "Y"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StationKey.self)
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(String.self, forKey: .id)
        x = try container.decode(String.self, forKey: .x)
        y = try container.decode(String.self, forKey: .y)
    }
}



