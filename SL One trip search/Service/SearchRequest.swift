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

enum SLAPIURLComponentKeys {
    static let httpScheme  = "http"
    static let slHost = "api.sl.se"
    static let key = "key"
}

struct StationSearchRequest : SearchRequest {
    let url: URL
    private let apiPath = "api2/typeahead.json"
    init?(searchString: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = SLAPIURLComponentKeys.httpScheme
        urlComponents.host = SLAPIURLComponentKeys.slHost
        urlComponents.path = "/" + apiPath
        
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
