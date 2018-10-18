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

struct Station {
    let name: String
    let area: String
    let id: String
    let lat: Double
    let long: Double
}

struct StationSearchResult : Decodable {
    let values: [Station]
    enum StationCodingResultKey : String, CodingKey {
        case values = "ResponseData"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StationCodingResultKey.self)
        values = try container.decode([Station].self, forKey: .values)
    }
}

extension Station : Decodable {
    enum StationKey : String, CodingKey {
        case name = "Name"
        case id = "SiteId"
        case X, Y
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StationKey.self)
        var tempName = try container.decode(String.self, forKey: .name)
        id = try container.decode(String.self, forKey: .id)
        var longString = try container.decode(String.self, forKey: .X)
        var latString = try container.decode(String.self, forKey: .Y)
        longString.insert(".", at: longString.index(longString.startIndex, offsetBy: 2))
        latString.insert(".", at: longString.index(longString.startIndex, offsetBy: 2))
        guard let long = Double(longString), let lat = Double(latString) else {
            throw StationDecodingError.errorCreatingCoordinates
        }
        self.lat = lat
        self.long = long
        if let areaParentheseStartIndex = tempName.firstIndex(of: "("),
            let areaParentheseEndIndex = tempName.firstIndex(of: ")") {
            let textStartIndex = tempName.index(areaParentheseStartIndex, offsetBy: 1)
            
            area = String(tempName[textStartIndex..<areaParentheseEndIndex])
            let removeStartIndex = tempName.index(areaParentheseStartIndex, offsetBy: -1)
            tempName.removeSubrange(removeStartIndex...areaParentheseEndIndex)
        } else {
            area = ""
        }
        
        name = tempName
    }
}



