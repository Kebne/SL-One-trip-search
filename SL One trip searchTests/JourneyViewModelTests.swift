//
//  JourneyViewModelTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-23.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
@testable import SL_One_trip_search

class JourneyViewModelTests: XCTestCase {
    
    var mockStateController: MockStateController!
    var mockUserJourneyController: MockUserJourneyController!
    var mockLocationManager: MockLocationManager!
    var sut: JourneyViewModel!

    override func setUp() {
        mockLocationManager = MockLocationManager()
        mockUserJourneyController = MockUserJourneyController()
        mockStateController = MockStateController(userController: mockUserJourneyController, journeyPlannerService: SearchService<SLJourneyPlanAPIResponse>(), locationService: LocationService(locationManager: mockLocationManager), notificationService: NotificationService())
        sut = JourneyViewModel(stateController: mockStateController)
    }

    override func tearDown() {
        sut = nil
        mockStateController = nil
        mockLocationManager = nil
        mockUserJourneyController = nil
    }

    func test_createsCorrectStringProperties_JourneySettings_more1min() {
        
        let minutesUntilSearch = 2
        let journeySettings = mockUserJourney(minutesUntilSearch: minutesUntilSearch)
        mockUserJourneyController.userJourney = journeySettings
        let expectedString = String(format: NSLocalizedString("journeyView.timeInfoLabel.moreThanOneMinute", comment: ""), "\(minutesUntilSearch)")
        
        sut.viewWillAppear()
        
        XCTAssertEqual(sut.timeString, expectedString)
        XCTAssertEqual(sut.start, journeySettings.start.name)
        XCTAssertEqual(sut.destination, journeySettings.destination.name)
        
    }
    
    func test_createsCorrectStringProperties_JourneySettings_0min() {
        
        let minutesUntilSearch = 0
        let journeySettings = mockUserJourney(minutesUntilSearch: minutesUntilSearch)
        mockUserJourneyController.userJourney = journeySettings
        let expectedString = NSLocalizedString("journeyView.timeInfoLabel.zeroMinutes", comment: "")
        
        sut.viewWillAppear()
        
        XCTAssertEqual(sut.timeString, expectedString)
        XCTAssertEqual(sut.start, journeySettings.start.name)
        XCTAssertEqual(sut.destination, journeySettings.destination.name)
        
    }
    
    func test_createsCorrectStringProperties_JourneySettings_1min() {
        
        let minutesUntilSearch = 1
        let journeySettings = mockUserJourney(minutesUntilSearch: minutesUntilSearch)
        mockUserJourneyController.userJourney = journeySettings
        let expectedString = NSLocalizedString("journeyView.timeInfoLabel.oneMinute", comment: "")
        
        sut.viewWillAppear()
        
        XCTAssertEqual(sut.timeString, expectedString)
        XCTAssertEqual(sut.start, journeySettings.start.name)
        XCTAssertEqual(sut.destination, journeySettings.destination.name)
        
    }
    
    func test_receivesCallback_calling_viewWillAppear() {
        
        var didReceiveCallback = false
        sut.newJourneyClosure = {
            didReceiveCallback = true
        }
        
        sut.viewWillAppear()
        
        XCTAssertTrue(didReceiveCallback)
    }
    
    func test_createsCorrectSectionTitles_busAndMetroResponse() {
        sut.newJourneyClosure = nil
        mockStateController.jsonString = StubGenerator.jsonStringMetroBusTrip
        
        sut.viewWillAppear()
        let expectedBusSectionTitle = NSLocalizedString("product.bus.categoryName", comment: "") + " " + NSLocalizedString("towards", comment: "")
        let expectedMetroSectionTitle = NSLocalizedString("product.metro.categoryName", comment: "") + " " + NSLocalizedString("towards", comment: "")
        
        
        guard let section0Title = sut.titleFor(section: 0), let section1Title = sut.titleFor(section: 1) else {
            XCTFail("Test failed, correct section titles weren't created")
            return
        }
        
        let sectionTitles = [section0Title, section1Title]
        
        XCTAssertTrue(sectionTitles.contains(expectedBusSectionTitle))
        XCTAssertTrue(sectionTitles.contains(expectedMetroSectionTitle))
        
    }
    
    func test_createsJourneyViewModels_busAndMetroResponse() {
        sut.newJourneyClosure = nil
        mockStateController.jsonString = StubGenerator.jsonStringMetroBusTrip
        sut.viewWillAppear()
    
        XCTAssertNotNil(sut.cellModelFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertNotNil(sut.cellModelFor(indexPath: IndexPath(row: 0, section: 1)))
        
    }
    
    func test_correctNrOfSections_busAndMetroResponse() {
        sut.newJourneyClosure = nil
        mockStateController.jsonString = StubGenerator.jsonStringMetroBusTrip
        
        sut.viewWillAppear()
        XCTAssertTrue(sut.nrOfSections == 2)
    }
    
    func test_nrOfRowsInSection_busAndMetroResponse() {
        let expectedNrOfRowsSection0 = 6
        let expectedNrOfRowsSection1 = 1
        mockStateController.jsonString = StubGenerator.jsonStringMetroBusTrip
        
        sut.viewWillAppear()
        let nrOFRowsSection0 = sut.nrOfRowsIn(section: 0)
        let nrOFRowsSection1 = sut.nrOfRowsIn(section: 1)
        XCTAssertEqual(expectedNrOfRowsSection0, nrOFRowsSection0)
        XCTAssertEqual(expectedNrOfRowsSection1, nrOFRowsSection1)
    }
    
    func test_swapStation_delegatesCall() {
        mockUserJourneyController.didCallSwapStations = false
        sut.didPressSwapButton()
        
        XCTAssertTrue(mockUserJourneyController.didCallSwapStations)
    }
    
    
    func test_journeyViewModel_correctPropertiesFrom_trip() {
        let directionName = "Direction"
        let trackName = "A"
        let expectedTimeString = "nu"
        
        
        let trip = Trip(legList: [StubGenerator.leg])
        
        let journeyCellViewModelSUT = JourneyTableViewCell.ViewModel(trip: trip)
        
        XCTAssertEqual(directionName, journeyCellViewModelSUT.destination)
        XCTAssertEqual(trackName, journeyCellViewModelSUT.track)
        XCTAssertEqual(expectedTimeString, journeyCellViewModelSUT.time)
        
    }
    
    
    
    func mockUserJourney(minutesUntilSearch: Int) ->UserJourney {
        return UserJourney(start: StubGenerator.startStation, destination: StubGenerator.destinationStation, minutesUntilSearch: minutesUntilSearch, monitorStationProximity: false)
    }
}




