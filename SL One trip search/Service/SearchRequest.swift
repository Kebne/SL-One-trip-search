//
//  SearchRequest.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-18.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

protocol SearchRequest {
    var url: URL {get}
}

extension Date {
    func dateByAdding(_ minutes: Int) ->Date {
        return self.addingTimeInterval(Double(minutes * 60))
    }
    
    var slRequestTimeString: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: self)
    }
    
    var slRequestDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}

enum SLAPIURLComponentKeys {
    static let httpScheme  = "http"
    static let slHost = "api.sl.se"
    static let key = "key"
    
    static func standardSLAPIURLComponentsWith(path: String) ->URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = SLAPIURLComponentKeys.httpScheme
        urlComponents.host = SLAPIURLComponentKeys.slHost
        urlComponents.path = "/" + path
      
        return urlComponents
    }
}

struct StationSearchRequest : SearchRequest {
    let url: URL
    private let apiPath = "api2/typeahead.json"
    init?(searchString: String) {
        var urlComponents = SLAPIURLComponentKeys.standardSLAPIURLComponentsWith(path: apiPath)
        
        let keyQuery = URLQueryItem(name: SLAPIURLComponentKeys.key, value: Environment.stationAPIKey)
        let searchStringQuery = URLQueryItem(name: "searchstring", value: searchString)
        let stationsOnlyQuery = URLQueryItem(name: "stationsonly", value: "true")
        urlComponents.queryItems = [keyQuery, searchStringQuery, stationsOnlyQuery]
        
        guard let url = urlComponents.url else {
            return nil
        }
        self.url = url
    }
}

struct JourneySearchRequest : SearchRequest {
    let url: URL
    private let apiPath = "api2/TravelplannerV3/trip.json"
    init?(originId: String, destinationId: String, minutesFromNow: Int) {
        var urlComponents = SLAPIURLComponentKeys.standardSLAPIURLComponentsWith(path: apiPath)
        
        let keyQuery = URLQueryItem(name: SLAPIURLComponentKeys.key, value: Environment.journeyPlanAPIKey)
        let originQueryItem = URLQueryItem(name: "originId", value: originId)
        let destinationQueryItem = URLQueryItem(name: "destId", value: destinationId)
        let date = Date().dateByAdding(minutesFromNow)
        let dateQueryItem = URLQueryItem(name: "date", value: date.slRequestDateString)
        let timeQueryItem = URLQueryItem(name: "time", value: date.slRequestTimeString)
        let stopsQueryItem = URLQueryItem(name: "passlist", value: "1")
        let polyItem = URLQueryItem(name: "poly", value: "1")
        urlComponents.queryItems = [keyQuery, originQueryItem, destinationQueryItem, dateQueryItem, timeQueryItem, stopsQueryItem, polyItem]
        guard let url = urlComponents.url else {
            return nil
        }
        self.url = url
        
    }
}


