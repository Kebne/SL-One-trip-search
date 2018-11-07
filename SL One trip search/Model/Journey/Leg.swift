//
//  Leg.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-22.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation



struct Leg  {
    let origin: Origin
    let destination: Destination
    let id: Int
    let transportType: TransportType
    let hidden: Bool
    let direction: String
    
}

extension Leg : Decodable {
    enum CodingKeys : String, CodingKey {
        case origin = "Origin"
        case destination = "Destination"
        case id = "idx"
        case product = "Product"
        case direction
        case type
        case dist
        case hide
    }
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        origin = try root.decode(Origin.self, forKey: .origin)
        destination = try root.decode(Destination.self, forKey: .destination)
        let idString = try root.decode(String.self, forKey: .id)
        id = Int(idString) ?? -1
        let type = try root.decode(String.self, forKey: .type)
        let walkingDistance = (try? root.decode(Int.self, forKey: .dist)) ?? 0
        hidden = (try? root.decode(Bool.self, forKey: .hide)) ?? false
        if let product = try? root.decode(Product.self, forKey: .product) {
            transportType = TransportType.product(product)
        } else if type == "WALK" {
            transportType = TransportType.walk(walkingDistance)
        } else {
            transportType = TransportType.product(Product(category: .unknown, name: "", line: ""))
        }
        if let direction = try? root.decode(String.self, forKey: .direction) {
            self.direction = direction
        } else {
            direction = ""
        }
        
    }
}

extension Leg: CustomStringConvertible {
    // Buss 300, mot, Nacka, hållplatsläge, -, 3 min
    var description: String {
        return direction.appendSpace() + transportType.platformTypeString.appendSpace() + origin.track + " - " + origin.time.presentableTimeString
    }
}
