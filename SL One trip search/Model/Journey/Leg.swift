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
    let stops: [Stop]
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
        case stops = "Stops"
    }
    
    enum StopKeys : String, CodingKey {
        case stop = "Stop"
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
        
        var allStops = [Stop]()
        if let stopContainer = try? root.nestedContainer(keyedBy: StopKeys.self, forKey: .stops) {
            allStops = try stopContainer.decode([Stop].self, forKey: .stop)
        }
        stops = allStops
        
    }
}

extension Leg: CustomStringConvertible {
    var description: String {
        return direction.appendSpace() + transportType.platformTypeString.appendSpace() + origin.track + " - " + origin.time.presentableTimeString
    }
}
