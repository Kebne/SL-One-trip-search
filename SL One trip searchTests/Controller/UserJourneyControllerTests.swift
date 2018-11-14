//
//  UserJourneyControllerTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-18.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
import CoreLocation
@testable import SL_One_trip_search

class UserJourneyControllerTests: XCTestCase {
    
    var sut: UserJourneyController!
    var mockedPersistService: MockPersistService!
    var mockLocationManager: MockLocationManager!
    var mockLocationService: PartialMockLocationService!

    override func setUp() {
        mockLocationManager = MockLocationManager()
        mockLocationService = PartialMockLocationService(locationManager: mockLocationManager)
        mockedPersistService = MockPersistService(UserDefaults.standard)
        sut = UserJourneyController(persistService: mockedPersistService, locationService: mockLocationService)
    }

    override func tearDown() {
        mockLocationService = nil
        mockLocationManager = nil
        mockedPersistService = nil
        sut = nil
    }
    
    func test_callsRetreive_onPersistService() {
        mockedPersistService.didCallRetreive = false
        sut.attemptToRetreiveStoredJourney()
        
        XCTAssertTrue(mockedPersistService.didCallRetreive)
    }

    func test_noUserCreated_withoutAllStations() {
        
        sut.userJourney = nil
        sut.start = StubGenerator.startStation
        sut.destination = nil
        
        XCTAssertNil(sut.userJourney)
        
    }
    
    func test_userIsCreated_AllStationsAreSet() {
  
        sut.userJourney = nil
        sut.start = StubGenerator.startStation
        sut.destination = StubGenerator.destinationStation
        sut.destination = nil
        
        XCTAssertNotNil(sut.userJourney)
    }
    
    func test_startStopStationsAreCorrect() {
        
        sut.userJourney = nil
        sut.start = StubGenerator.startStation
        sut.destination = StubGenerator.destinationStation
        
        guard let journey = sut.userJourney else {
            XCTFail( "Journey shouldn't be nil here!")
            return
        }
        
        XCTAssertEqual(journey.start.name, StubGenerator.startStation.name)
        XCTAssertEqual(journey.destination.name, StubGenerator.destinationStation.name)
        
    }
    
    func test_Swap_StartAndDestination() {
        
        let startUserJourney = UserJourney(start: StubGenerator.startStation,
                                           destination: StubGenerator.destinationStation, minutesUntilSearch: 0, monitorStationProximity: false)
        sut.userJourney = startUserJourney
        sut.swapStations()
        
        XCTAssertEqual(startUserJourney.start.id, sut.userJourney!.destination.id)
        XCTAssertEqual(startUserJourney.destination.id, sut.userJourney!.start.id)
        XCTAssertEqual(startUserJourney.minutesUntilSearch, sut.userJourney!.minutesUntilSearch)
        XCTAssertEqual(startUserJourney.monitorStationProximity, sut.userJourney!.monitorStationProximity)
    }
    
    func test_TimeValue_isSet() {
        sut.userJourney = nil
        sut.start = StubGenerator.startStation
        sut.destination = StubGenerator.destinationStation
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
        sut.start = StubGenerator.startStation
        sut.destination = StubGenerator.destinationStation
        let monitor = false
        sut.monitorStationProximity = monitor
        
        guard let journey = sut.userJourney else {
            XCTFail( "Journey shouldn't be nil here!")
            return
        }
        
        XCTAssertEqual(journey.monitorStationProximity, monitor)
    }
    
    func test_regionMonitoringStarts_changingStation() {
        
        let userJourney = UserJourney(start: StubGenerator.startStation, destination: StubGenerator.destinationStation, minutesUntilSearch: 0, monitorStationProximity: true)
        MockLocationManager.authStatus = .authorizedAlways
        sut.userJourney = userJourney
        
        sut.timeFromNowUntilSearch = 1
        
        XCTAssertEqual(mockLocationManager.monitoredRegions.count, 2)
        XCTAssertTrue(mockLocationManager.monitoredRegions.contains(where: {$0.identifier == StubGenerator.startStation.id}))
        XCTAssertTrue(mockLocationManager.monitoredRegions.contains(where: {$0.identifier == StubGenerator.destinationStation.id}))
        
    }
    
    func test_regionMonitoringCorrectRegions_changingStation() {
        
        let userJourney = UserJourney(start: StubGenerator.startStation, destination: StubGenerator.destinationStation, minutesUntilSearch: 0, monitorStationProximity: true)
        MockLocationManager.authStatus = .authorizedAlways
        sut.userJourney = userJourney
        
        sut.timeFromNowUntilSearch = 1
        
        let updatedStation = Station(name: "Next", area: "area", id: "12", lat: 0.1, long: 0.1)
        sut.destination = updatedStation
        
        XCTAssertEqual(mockLocationManager.monitoredRegions.count, 2)
        XCTAssertTrue(mockLocationManager.monitoredRegions.contains(where: {$0.identifier == StubGenerator.startStation.id}))
        XCTAssertTrue(mockLocationManager.monitoredRegions.contains(where: {$0.identifier == updatedStation.id}))
        
    }
    
    func test_noRegionsAreMonitored_regionMonitoringDisabled() {
        let userJourney = UserJourney(start: StubGenerator.startStation, destination: StubGenerator.destinationStation, minutesUntilSearch: 0, monitorStationProximity: true)
        MockLocationManager.authStatus = .authorizedAlways
        sut.userJourney = userJourney
        
        sut.timeFromNowUntilSearch = 1
        
        XCTAssertEqual(mockLocationManager.monitoredRegions.count, 2)
        sut.monitorStationProximity = false
        XCTAssertEqual(mockLocationManager.monitoredRegions.count, 0)
    }
    
    

}






