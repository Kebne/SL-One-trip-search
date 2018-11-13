//
//  MainCoordinatorTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-29.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
@testable import SL_One_trip_search

class MainCoordinatorTests: XCTestCase {
    
    var sut: MainCoordinator!
    var mockNavController: MockNavigationController!
    var mockWindow: MockWindow!
    var mockUserJourneyController: MockUserJourneyController!
    var mockStateController: MockStateController!

    override func setUp() {
        mockNavController = MockNavigationController()
        mockWindow = MockWindow()
        mockUserJourneyController = MockUserJourneyController()
        mockStateController = MockStateController(userController: mockUserJourneyController, journeyPlannerService: SearchService<SLJourneyPlanAPIResponse>(), locationService: LocationService(locationManager: MockLocationManager()), notificationService: NotificationService())
        sut = MainCoordinator(stateController: mockStateController, window: mockWindow, viewControllerFactory: ViewControllerFactoryClass(storyboard: UIStoryboard.main),
                              rootNavigationController: mockNavController)
    }

    override func tearDown() {
        mockNavController = nil
        mockWindow = nil
        mockUserJourneyController = nil
        mockStateController = nil
        sut = nil
    }
    
    func test_start_setsRootVC_callsMakeKey() {
        
        mockWindow.didCallMakeKey = false
        mockWindow.didSetRootVC = false
        
        sut.start()
        
        XCTAssertTrue(mockWindow.didCallMakeKey)
        XCTAssertTrue(mockWindow.didSetRootVC)
        
    }
    
    func test_start_showsSettings_ifNoUserJourney() {
        mockUserJourneyController.userJourney = nil
        
        sut.start()
        
        guard let nextVC = mockNavController.viewControllers.last else {
            XCTFail("No view controller was pushed")
            return
        }
        
        XCTAssertTrue(nextVC is SettingsViewController)
    }
    
    func test_start_showsJourney_ifUserJourney() {
        mockUserJourneyController.userJourney = StubGenerator.userJourney
        
        sut.start()
        
        guard let nextVC = mockNavController.viewControllers.last else {
            XCTFail("No view controller was pushed")
            return
        }
        
        XCTAssertTrue(nextVC is JourneyViewController)
    }
    
    func test_start_noUserJourney_pushesJourney_and_settingsVC() {
        mockUserJourneyController.userJourney = nil
        mockNavController.viewControllers.removeAll()
        sut.start()
        
        guard let journeyVC = mockNavController.viewControllers.first, let settingsVc = mockNavController.viewControllers.last else {
            XCTFail("Correct view controllers were not pushed in the right order")
            return
        }
        
        XCTAssertTrue(journeyVC is JourneyViewController)
        XCTAssertTrue(settingsVc is SettingsViewController)
        XCTAssertTrue(mockNavController.viewControllers.count == 2)
    }
    
    func test_receivesFromURL_opensSearchVC_fromStation_userJourneyExists() {
        mockUserJourneyController.userJourney = StubGenerator.userJourney
        mockNavController.viewControllers.removeAll()
        let fromURL = URL.fromStation
        
        let handleResponse = sut.handle(url: fromURL)
        
        let lastVC = mockNavController.viewControllers.last as? SearchViewController
        
        XCTAssertNotNil(lastVC)
        XCTAssertTrue(handleResponse)
      
    }
    
    func test_receivesFromURL_pushesSettingsVCOnce_fromStation_NOuserJourneyExists() {
        mockUserJourneyController.userJourney = nil
        mockNavController.viewControllers.removeAll()
        let fromURL = URL.fromStation
        
        let handleResponse = sut.handle(url: fromURL)
        
        guard let topVC = mockNavController.viewControllers.last else {
            XCTFail("No view controller was pushed, test failed")
            return
        }
        
        XCTAssertTrue(handleResponse)
        XCTAssertTrue(mockNavController.viewControllers.filter({$0 is SettingsViewController}).count == 1)
        XCTAssertTrue(topVC is SettingsViewController)
    }
    
    func test_receivesFromURL_opensSearchVC_destStation_userJourneyExists() {
        mockUserJourneyController.userJourney = StubGenerator.userJourney
        mockNavController.viewControllers.removeAll()
        let fromURL = URL.destStation
        
        let handleResponse = sut.handle(url: fromURL)
        
        let lastVC = mockNavController.viewControllers.last as? SearchViewController
        
        XCTAssertNotNil(lastVC)
        XCTAssertTrue(handleResponse)
        
    }
    
    func test_receivesFromURL_pushesSettingsVCOnce_destStation_NOuserJourneyExists() {
        mockUserJourneyController.userJourney = nil
        mockNavController.viewControllers.removeAll()
        let fromURL = URL.destStation
        
        let handleResponse = sut.handle(url: fromURL)
        
        guard let topVC = mockNavController.viewControllers.last else {
            XCTFail("No view controller was pushed, test failed")
            return
        }
        
        XCTAssertTrue(handleResponse)
        XCTAssertTrue(mockNavController.viewControllers.filter({$0 is SettingsViewController}).count == 1)
        XCTAssertTrue(topVC is SettingsViewController)
    }
    

}




