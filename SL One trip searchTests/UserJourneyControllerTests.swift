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
    
    func test_Swap_StartAndDestination() {
        
        let startUserJourney = UserJourney(start: UserJourneyControllerTests.mockStart,
                                           destination: UserJourneyControllerTests.mockEnd, minutesUntilSearch: 0, monitorStationProximity: false)
        sut.userJourney = startUserJourney
        sut.swapStations()
        
        XCTAssertEqual(startUserJourney.start.id, sut.userJourney!.destination.id)
        XCTAssertEqual(startUserJourney.destination.id, sut.userJourney!.start.id)
        XCTAssertEqual(startUserJourney.minutesUntilSearch, sut.userJourney!.minutesUntilSearch)
        XCTAssertEqual(startUserJourney.monitorStationProximity, sut.userJourney!.monitorStationProximity)
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
    
    func test_regionMonitoringStarts_changingStation() {
        
        let userJourney = UserJourney(start: UserJourneyControllerTests.mockStart, destination: UserJourneyControllerTests.mockEnd, minutesUntilSearch: 0, monitorStationProximity: true)
        MockLocationManager.authStatus = .authorizedAlways
        sut.userJourney = userJourney
        
        sut.timeFromNowUntilSearch = 1
        
        XCTAssertEqual(mockLocationManager.monitoredRegions.count, 2)
        XCTAssertTrue(mockLocationManager.monitoredRegions.contains(where: {$0.identifier == UserJourneyControllerTests.mockStart.id}))
        XCTAssertTrue(mockLocationManager.monitoredRegions.contains(where: {$0.identifier == UserJourneyControllerTests.mockEnd.id}))
        
    }
    
    func test_regionMonitoringCorrectRegions_changingStation() {
        
        let userJourney = UserJourney(start: UserJourneyControllerTests.mockStart, destination: UserJourneyControllerTests.mockEnd, minutesUntilSearch: 0, monitorStationProximity: true)
        MockLocationManager.authStatus = .authorizedAlways
        sut.userJourney = userJourney
        
        sut.timeFromNowUntilSearch = 1
        
        let updatedStation = Station(name: "Next", area: "area", id: "12", lat: 0.1, long: 0.1)
        sut.destination = updatedStation
        
        XCTAssertEqual(mockLocationManager.monitoredRegions.count, 2)
        XCTAssertTrue(mockLocationManager.monitoredRegions.contains(where: {$0.identifier == UserJourneyControllerTests.mockStart.id}))
        XCTAssertTrue(mockLocationManager.monitoredRegions.contains(where: {$0.identifier == updatedStation.id}))
        
    }
    
    static var mockStart : Station {
        return Station(name: "Start",area: "area", id: "10", lat: 0.0, long: 0.0)
    }
    
    static var mockEnd : Station {
        return Station(name: "Destination",area: "area", id: "11", lat: 0.0, long: 0.0)
    }

}

class MockPersistService : PersistServiceProtocol {
    
    var didCallRetreive = false
    
    func persist<T>(value: T, forKey key: String) where T : Encodable {
        
    }
    
    func retreive<T>(_ type: T.Type, valueForKey key: String) -> T? where T : Decodable {
        didCallRetreive = true
        return nil
    }
    
    required init(_ userDefaults: UserDefaultProtocol) {
        
    }
    
    
}

class PartialMockLocationService : LocationService {
    override func locationServicesIsAuthorized() -> Bool {
        return MockLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    override func monitoringIsAvailable() -> Bool {
        return MockLocationManager.isMonitoringAvailable(for: CLCircularRegion.classForCoder())
    }
}


