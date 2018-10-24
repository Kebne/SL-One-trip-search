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
    
    func test_journeySearch_buildsCorrectURL() {
        
        let originId = "1000"
        let destinationId = "2000"
        let minutesFromNow = 5
        let expectedDate = Date().dateByAdding(minutesFromNow)
        let expectedDateString = expectedDate.slRequestDateString
        let expectedTimeString = expectedDate.slRequestTimeString
        let expectedResultURLString = "http://api.sl.se/api2/TravelplannerV3/trip.json?key=" + Environment.journeyPlanAPIKey + "&originId=" + originId + "&destId=" + destinationId + "&date=" + expectedDateString + "&time=" + expectedTimeString
        
        guard let request = JourneySearchRequest(originId: originId, destinationId: destinationId, minutesFromNow: minutesFromNow) else {
            XCTFail("Unable to construct journey search request")
            return
        }
        
        XCTAssertEqual(expectedResultURLString, request.url.absoluteString)
        
    }

}
