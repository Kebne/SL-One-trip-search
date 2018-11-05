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
    
    enum PersistKey {
        static let trip = "Trip"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LegListKey.self)
        let list = try container.nestedContainer(keyedBy: LegKey.self, forKey:.legList)
        legList = try list.decode([Leg].self, forKey: .leg)
    }
}


typealias SortedTripInfo = (sortedKeys: [ProductCategory], dictionary: [ProductCategory:[Trip]])

extension Trip {
    
    static func sortInCategories(trips: [Trip]) ->SortedTripInfo {
        var result = [ProductCategory:[Trip]]()
        let firstLegs = trips.reduce([Leg]()) {legs, nextTrip in
            if let nextLeg = nextTrip.legList.first(where: {$0.id == 0}), nextLeg.direction.count > 0 && nextLeg.product.line.count > 0 {
                return legs + [nextLeg]
            }
            return legs
        }
        var categories = firstLegs.reduce([ProductCategory]()) {array, nextLeg ->[ProductCategory] in
            array.contains(nextLeg.product.category) ? array : array + [nextLeg.product.category]
        }
        
        for category in categories {
            result[category] = trips.filter({$0.legList[0].product.category == category && $0.legList[0].direction.count > 0})
        }
        
        categories.sort(by: {(first, second) in
            let firstFastestLeg = result[first]!.sorted(by: {$0.arrivalDate < $1.arrivalDate})[0]
            let secondFastestLeg = result[second]!.sorted(by: {$0.arrivalDate < $1.arrivalDate})[0]
            
            return firstFastestLeg.arrivalDate < secondFastestLeg.arrivalDate
        })
        
        return (sortedKeys: categories, dictionary: result)
    }
}
