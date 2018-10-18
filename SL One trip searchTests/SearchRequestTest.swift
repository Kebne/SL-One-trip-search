//
//  SearchRequestTest.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-18.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
@testable import SL_One_trip_search

class SearchRequestTest: XCTestCase {

    func test_stationSearch_buildsCorrectURL() {
        
        let searchString = "station"
        let expectedResult = "http://api.sl.se/api2/typeahead.json?key=\(Environment.stationAPIKey)&searchstring=\(searchString)&stationsonly=true"
        guard let request = StationSearchRequest(searchString: searchString) else {
            XCTFail("Station search request was not able to be created.")
            return
        }
        
        XCTAssertEqual(expectedResult, request.url.absoluteString)
    }

}
