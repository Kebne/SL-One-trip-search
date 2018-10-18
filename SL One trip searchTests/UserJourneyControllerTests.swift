//
//  UserJourneyControllerTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-18.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
@testable import SL_One_trip_search

class UserJourneyControllerTests: XCTestCase {
    
    var sut: UserJourneyController!

    override func setUp() {
        sut = UserJourneyController()
    }

    override func tearDown() {
        sut = nil
    }

    func test_noUserCreated_withoutAllStations() {
        
        sut.userJourney = nil
        sut.start = UserJourneyControllerTests.mockStart
        sut.destination = nil
        
        XCTAssertNil(sut.userJourney)
        
    }
    
    func test_userIsCreated_AllStationsAreSet() {
  
        sut.userJourney = nil
        sut.start = UserJourneyControllerTests.mockStart
        sut.destination = UserJourneyControllerTests.mockEnd
        sut.destination = nil
        
        XCTAssertNotNil(sut.userJourney)
    }
    
    func test_startStopStationsAreCorrect() {
        
        sut.userJourney = nil
        sut.start = UserJourneyControllerTests.mockStart
        sut.destination = UserJourneyControllerTests.mockEnd
        
        guard let journey = sut.userJourney else {
            XCTFail( "Journey shouldn't be nil here!")
            return
        }
        
        XCTAssertEqual(journey.start.name, UserJourneyControllerTests.mockStart.name)
        XCTAssertEqual(journey.destination.name, UserJourneyControllerTests.mockEnd.name)
        
    }
    
    func test_TimeValue_isSet() {
        sut.userJourney = nil
        sut.start = UserJourneyControllerTests.mockStart
        sut.destination = UserJourneyControllerTests.mockEnd
        let minutes = 5
        sut.timeFromNowUntilSearch = minutes
        
        guard let journey = sut.userJourney else {
            XCTFail( "Journey shouldn't be nil here!")
            return
        }
        
        XCTAssertEqual(journey.minutesUntilSearch, minutes)
    }
    
    func test_MonitorValue_isSet() {
        sut.userJourney = nil
        sut.start = UserJourneyControllerTests.mockStart
        sut.destination = UserJourneyControllerTests.mockEnd
        let monitor = false
        sut.monitorStationProximity = monitor
        
        guard let journey = sut.userJourney else {
            XCTFail( "Journey shouldn't be nil here!")
            return
        }
        
        XCTAssertEqual(journey.monitorStationProximity, monitor)
    }
    
    static var mockStart : Station {
        return Station(name: "Start",area: "area", id: "10", lat: 0.0, long: 0.0)
    }
    
    static var mockEnd : Station {
        return Station(name: "Destination",area: "area", id: "11", lat: 0.0, long: 0.0)
    }

}
