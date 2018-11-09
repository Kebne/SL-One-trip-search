//
//  Trip.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-22.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
import MapKit

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
    // Return both the trips sorted by categories as a dictionary, and also a sorted array of categories, sorted by fastest arrival time.
    static func sortInCategories(trips: [Trip]) ->SortedTripInfo {
        var result = [ProductCategory:[Trip]]()
        // Extract first part of the trip, the first leg.
        let firstLegs = trips.reduce([Leg]()) {legs, nextTrip in
            if let nextLeg = nextTrip.legList.first(where: {$0.id == 0}), nextLeg.direction.count > 0  {
                switch nextLeg.transportType {
                case .product(_): return legs + [nextLeg]
                default: return legs
                }
                
            }
            return legs
        }
        // For each first leg, get the category (bus, metro etc).
        var categories = firstLegs.reduce([ProductCategory]()) {array, nextLeg ->[ProductCategory] in
            switch nextLeg.transportType {
            case .product(let product): return array.contains(product.category) ? array : array + [product.category]
            default: return array
            }
            
        }
        
        // Get the trips for each category
        for category in categories {
//            result[category] = trips.filter({$0.legList[0].product.category == category && $0.legList[0].direction.count > 0}).sorted(by: {$0.arrivalDate < $1.arrivalDate})
            result[category] = trips.filter({(trip) in
                if case .product(let p) = trip.legList[0].transportType {
                    return p.category == category
                }
                return false
            }).sorted(by: {$0.arrivalDate < $1.arrivalDate})
        }
        
        // Sort the categories so that the one with that contains the trip with the fastest arrival time is first...
        categories.sort(by: {(first, second) in
            let firstFastestLeg = result[first]!.sorted(by: {$0.arrivalDate < $1.arrivalDate})[0]
            let secondFastestLeg = result[second]!.sorted(by: {$0.arrivalDate < $1.arrivalDate})[0]
            
            return firstFastestLeg.arrivalDate < secondFastestLeg.arrivalDate
        })
        
        return (sortedKeys: categories, dictionary: result)
    }
}


extension Trip {
    private struct Region {
        let minLat: Double
        let maxLat: Double
        let minLong: Double
        let maxLong: Double
    }
    var mkRegion: MKCoordinateRegion {
            let sortedLegs = legList.sorted(by: {$0.id < $1.id})
            guard let start = sortedLegs.first, let end = sortedLegs.last else {
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 59.332790, longitude: 18.064490), latitudinalMeters: 10000.0, longitudinalMeters: 10000.0)
        }
        
        
        let region = sortedLegs.reduce(Region(minLat: start.origin.latitude, maxLat: end.destination.latitude, minLong: start.origin.longitude, maxLong: end.destination.longitude), {(result, nextLeg) in
            return nextLeg.coordinates.reduce(result, {(innerResult, nextCoordinate) in
                return updatedRegionFrom(coordinate: nextCoordinate, current: innerResult)
            })
        })
        
        let latitudeDelta = (region.maxLat - region.minLat)
        let longitudeDelta = (region.maxLong - region.minLong)
        let centerCoordinate = CLLocationCoordinate2D(latitude: region.minLat + (latitudeDelta / 2.0), longitude: region.minLong + (longitudeDelta / 2.0))
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta * 1.3, longitudeDelta: longitudeDelta * 1.3)
        
        return MKCoordinateRegion(center: centerCoordinate, span: span)
    }
    
    private func updatedRegionFrom(coordinate: CLLocationCoordinate2D, current: Region) ->Region {
        
        return Region(minLat: min(current.minLat, coordinate.latitude),
                      maxLat: max(current.maxLat, coordinate.latitude),
                      minLong: min(current.minLong, coordinate.longitude),
                      maxLong: max(current.maxLong, coordinate.longitude))
        
        
    }
    

    
    
}
