//
//  StateControllerTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-31.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
import CoreLocation
@testable import SL_One_trip_search

class StateControllerTests: XCTestCase {
    
    var sut: StateController!
    var mockLocationManager: MockLocationManager!
    var mockUserJourneyController: MockUserJourneyController!
    var mockSearchService: MockJourneyPlanSearchService!
    var partialMockLocationService: PartialMockLocationService!
    var partialMockNotificationService: PartialMockNotificationService!

    override func setUp() {
        mockLocationManager = MockLocationManager()
        mockSearchService = MockJourneyPlanSearchService()
        mockUserJourneyController = MockUserJourneyController()
        partialMockLocationService = PartialMockLocationService(locationManager: mockLocationManager)
        partialMockNotificationService = PartialMockNotificationService()
        sut = StateController(userController: mockUserJourneyController, journeyPlannerService: mockSearchService, locationService: partialMockLocationService, notificationService: partialMockNotificationService)
        
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
    
    func test_performsSearchWithPersist_receivingRegionEvent() {
        
        mockSearchService.didCallSearch = false
        mockSearchService.persistDataKey = nil
        mockUserJourneyController.userJourney = UserJourney(start: StubGenerator.startStation, destination:StubGenerator.destinationStation, minutesUntilSearch: 0, monitorStationProximity: true)
        
        mockLocationManager.notifyDelegateDidEnter(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                                                                            radius: 400.0, identifier: "Test"))
        
        XCTAssertTrue(mockSearchService.didCallSearch)
        XCTAssertNotNil(mockSearchService.persistDataKey)
        
    }
    
    func test_callsNotificationService_receivesRegionEvent_successfulTripSearch() {
        partialMockNotificationService.didCallNotifyTrips = false
        mockSearchService.callbackWithSuccess = true
        mockUserJourneyController.userJourney = UserJourney(start: StubGenerator.startStation, destination: StubGenerator.destinationStation, minutesUntilSearch: 0, monitorStationProximity: true)
        
        mockLocationManager.notifyDelegateDidEnter(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                                                                            radius: 400.0, identifier: "Test"))
        
        XCTAssertTrue(partialMockNotificationService.didCallNotifyTrips)
    }
    
    func test_doesNotCallNotificationService_receivesRegionEvent_unsuccessfulTripSearch() {
        partialMockNotificationService.didCallNotifyTrips = false
        mockSearchService.callbackWithSuccess = false
        mockUserJourneyController.userJourney = UserJourney(start: StubGenerator.startStation, destination: StubGenerator.destinationStation, minutesUntilSearch: 0, monitorStationProximity: true)
        
        mockLocationManager.notifyDelegateDidEnter(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                                                                            radius: 400.0, identifier: "Test"))
        
        XCTAssertFalse(partialMockNotificationService.didCallNotifyTrips)
    }


}





