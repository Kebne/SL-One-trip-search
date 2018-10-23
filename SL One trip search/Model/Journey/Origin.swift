//
//  Origin.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-22.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

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
}

protocol LegStart : Decodable {
    var track: String {get}
}

enum LegPointCodingKey : String, CodingKey {
    case time, date, rtTime, rtDate, name, track
}

struct Origin: LegPoint, LegStart{
    let name: String
    
    let time: Date
    
    let track: String
    
    static func create(from decoder: Decoder) throws ->(name: String, date: Date) {
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
        
        let time = Date.dateFromSLJourneyPlan(timeString: timeString, dateString: dateString)
        return (name: name,date: time)
    }
 
}


extension Origin {
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: LegPointCodingKey.self)
        let values = try Origin.create(from: decoder)
        name = values.name
        time = values.date
        if let trackString = try? root.decode(String.self, forKey: .track) {
            track = trackString
        } else {
            track = ""
        }
        
        
    }
    
    
}
