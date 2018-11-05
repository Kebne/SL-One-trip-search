//
//  JourneySearchTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-23.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
@testable import SL_One_trip_search

class JourneySearchTests: XCTestCase {
    
    var sut: SearchService<SLJourneyPlanAPIResponse>!
    var mockURLSession: MockURLSession!

    override func setUp() {
        mockURLSession = MockURLSession()
        sut = SearchService<SLJourneyPlanAPIResponse>(urlSession: mockURLSession)
    }

    override func tearDown() {
        sut = nil
        mockURLSession = nil
    }
    
    func test_decodes_singleBusTrip() {
        mockURLSession.jsonString = StubGenerator.jsonStringWithSingleBusTrip
        guard let request = JourneySearchRequest(originId: "1", destinationId: "2", minutesFromNow: 0) else {
            XCTFail("Unable to create journey search request")
            return
        }
        
        sut.searchWith(request: request, callback:  {result in
            switch result {
            case .success(let result): XCTAssertEqual(result.trips[0].legList[0].product.category, .bus)
            case .failure(_): XCTFail("Couldn't decode a trip from correct JSON.")
            }
        })
    }
    
    func test_calculatesCorrectDuration_busMetroTrip() {
        mockURLSession.jsonString = StubGenerator.jsonStringMetroBusTrip
        //originTime = "16:17:00"
        //destinationTime = "16:41:00"
        
        let expectedDurationSeconds = 24 * 60
        
        guard let request = JourneySearchRequest(originId: "1", destinationId: "2", minutesFromNow: 0) else {
            XCTFail("Unable to create journey search request")
            return
        }
        
        sut.searchWith(request: request, callback: {result in
            switch result {
            case .success(let result):
                guard let combinedTrip = result.trips.first(where: {$0.legList.contains(where: {$0.product.category == .metro})}) else {
                    XCTFail("Couldn't find combined metro / bus trip")
                    return
                }
                XCTAssertEqual(expectedDurationSeconds, Int(combinedTrip.duration))
                
            case .failure(_): XCTFail("Couldn't decode a trip from correct JSON.")
            }
        })
    }

}
