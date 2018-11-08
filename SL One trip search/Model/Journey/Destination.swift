//
//  Destination.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-22.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation


struct Destination : LegPoint {
    var longitude: Double
    
    var latitude: Double
    
    var name: String
    
    var time: Date
    
}

extension Destination {
    init(from decoder: Decoder) throws {
        let values = try Origin.create(from: decoder)
        name = values.name
        time = values.date
        latitude = values.lat
        longitude = values.lon
    }
}
