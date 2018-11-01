//
//  StateControllerTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-31.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
@testable import SL_One_trip_search

class StateControllerTests: XCTestCase {
    
    var sut: StateController!
    var mockLocationManager: MockLocationManager!
    var mockUserJourneyController: MockUserJourneyController!
    var mockSearchService: MockSearchService<SLJourneyPlanAPIResponse>!
    var partialMockLocationService: PartialMockLocationService!

    override func setUp() {
        mockLocationManager = MockLocationManager()
        mockSearchService = MockSearchService<SLJourneyPlanAPIResponse>()
        mockUserJourneyController = MockUserJourneyController()
        partialMockLocationService = PartialMockLocationService(locationManager: mockLocationManager)
        sut = StateController(userController: mockUserJourneyController, journeyPlannerService: mockSearchService, locationService: partialMockLocationService)
        
    }

    override func tearDown() {
        mockLocationManager = nil
        mockUserJourneyController = nil
        mockSearchService = nil
        sut = nil
    }
    
    func test_registers_regionObserver() {
        XCTAssertTrue(partialMockLocationService.didRegisterRegionObserver)
        
    }



}


class MockSearchService<T: Decodable> : SearchService<T> {
    
    var didCallSearch = false
    
    override func searchWith(request: SearchRequest, callback: @escaping (Result<T>) -> Void) {
        didCallSearch = true
    }
}
