//
//  Trip.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-22.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation



struct Trip  {
    let legList : [Leg]
    var duration : TimeInterval {
        let sortedLegs = legList.sorted(by: {$0.id < $1.id})
        guard let firstLeg = sortedLegs.first, let lastLeg = sortedLegs.last else {return -1}
        return abs(firstLeg.origin.time.timeIntervalSince(lastLeg.destination.time))
    }
    
    var arrivalDate : Date {
        let sortedLegs = legList.sorted(by: {$0.id < $1.id})
        guard let finalLeg = sortedLegs.last else {
            return Date()
        }
        return finalLeg.destination.time
    }
}

extension Trip : Decodable {
    enum LegKey : String, CodingKey {
        
        case leg = "Leg"
    }
    
    enum LegListKey : String, CodingKey{
        case legList  = "LegList"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LegListKey.self)
        let list = try container.nestedContainer(keyedBy: LegKey.self, forKey:.legList)
        legList = try list.decode([Leg].self, forKey: .leg)
    }
}
