//
//  Origin.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-22.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
import CoreLocation
extension Date {
    static func dateFromSLJourneyPlan(timeString: String, dateString: String) ->Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: dateString + " " + timeString) {
            return date
        }
        return Date()
    }
}

protocol LegPoint : Decodable {
    var name: String {get}
    var time: Date {get}
    var longitude: Double {get}
    var latitude: Double {get}
    var coordinate: CLLocationCoordinate2D {get}
}

extension LegPoint {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}




protocol LegStart : Decodable {
    var track: String {get}
}

enum LegPointCodingKey : String, CodingKey {
    case time, date, rtTime, rtDate, name, track, lat, lon
}

struct Origin: LegPoint, LegStart{
    var longitude: Double
    
    var latitude: Double
    
    let name: String
    
    let time: Date
    
    let track: String
    
    static func create(from decoder: Decoder) throws ->(name: String, date: Date, lon: Double, lat: Double) {
        let root = try decoder.container(keyedBy: LegPointCodingKey.self)
        let name = try root.decode(String.self, forKey: .name)
        var dateString = ""
        var timeString = ""
        if let rtDate = try? root.decode(String.self, forKey: .rtDate) {
            dateString = rtDate
        } else if let ttDate = try? root.decode(String.self, forKey: .date) {
            dateString = ttDate
        }
        
        if let rtTime = try? root.decode(String.self, forKey: .rtTime) {
            timeString = rtTime
        } else if let ttTime = try? root.decode(String.self, forKey: .time) {
            timeString = ttTime
        }
        
        let longitude = try root.decode(Double.self, forKey: .lon)
        let latitude = try root.decode(Double.self, forKey: .lat)
        
        let time = Date.dateFromSLJourneyPlan(timeString: timeString, dateString: dateString)
        
        return (name: name,date: time, lon: longitude, lat: latitude)
    }
 
}


extension Origin {
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: LegPointCodingKey.self)
        let values = try Origin.create(from: decoder)
        name = values.name
        time = values.date
        longitude = values.lon
        latitude = values.lat
        if let trackString = try? root.decode(String.self, forKey: .track) {
            track = trackString
        } else {
            track = ""
        }
        
        
    }
    
    
}

