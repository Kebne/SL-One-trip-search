//
//  Stop.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-08.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

typealias DepartureTime = Date
typealias ArrivalTime = Date

enum StopType {
    
    case start(DepartureTime)
    case stop(ArrivalTime, DepartureTime)
    case end(ArrivalTime)
}

struct Stop {
    let name: String
    let type: StopType
    let longitude: Double
    let latitude: Double
    
}

extension Stop : Decodable {
    enum CodingKeys : String, CodingKey {
        case name, depTime, depDate, arrTime, arrDate
        case rtDepTime, rtDepDate, rtArrTime, rtArrDate
        case lon, lat
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var arrivalTimeString = try? container.decode(String.self, forKey: .arrTime)
        var arrivalDateString = try? container.decode(String.self, forKey: .arrDate)
        var departureTimeString = try? container.decode(String.self, forKey: .depTime)
        var departureDateString = try? container.decode(String.self, forKey: .depDate)
        
        if let rt = try? container.decode(String.self, forKey: .rtArrTime) { arrivalTimeString = rt}
        if let rt = try? container.decode(String.self, forKey: .rtArrDate) { arrivalDateString = rt}
        if let rt = try? container.decode(String.self, forKey: .rtDepTime) { departureTimeString = rt}
        if let rt = try? container.decode(String.self, forKey: .rtDepDate) { departureDateString = rt}
        
        var stopType: StopType? = nil
        
        if arrivalTimeString == nil {
            guard let depTime = departureTimeString, let depDate = departureDateString else {throw EndpointError.corruptData}
            stopType = StopType.end(Date.dateFromSLJourneyPlan(timeString: depTime, dateString: depDate))
            
        } else if departureTimeString == nil {
            guard let arrTime = arrivalTimeString, let arrDate = arrivalDateString else {throw EndpointError.corruptData}
            stopType = StopType.start(Date.dateFromSLJourneyPlan(timeString: arrTime, dateString: arrDate))
        } else {
            guard let arrTime = arrivalTimeString, let arrDate = arrivalDateString,
                let depTime = departureTimeString, let depDate = departureDateString else {throw EndpointError.corruptData}
            stopType = StopType.stop(Date.dateFromSLJourneyPlan(timeString: arrTime, dateString: arrDate), Date.dateFromSLJourneyPlan(timeString: depTime, dateString: depDate))
        }
        
        guard let sType = stopType else {throw EndpointError.corruptData}
        type = sType
        
        
        name = try container.decode(String.self, forKey: .name)
        longitude = try container.decode(Double.self, forKey: .lon)
        latitude = try container.decode(Double.self, forKey: .lat)
        
    }
}
