//
//  JourneyViewControllerTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-24.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
@testable import SL_One_trip_search

class JourneyViewControllerTests: XCTestCase {
    
    var sut: JourneyViewController!
    var mockViewModel: MockJourneyViewModel!
    var mockNotificationCenter: MockNotificationCenter!

    override func setUp() {
        mockViewModel = MockJourneyViewModel()
        mockNotificationCenter = MockNotificationCenter()
        let vcFactory = ViewControllerFactoryClass(storyboard: UIStoryboard.main)
        sut = vcFactory.instantiateViewController()
        sut.viewModel = mockViewModel
        sut.notificationCenter = mockNotificationCenter
    }

    override func tearDown() {
        mockViewModel = nil
        mockNotificationCenter = nil
        sut = nil
    }

    func test_callsSwap_onViewModel() {
        
        mockViewModel.didCallSwap = false
        sut.didPressSwapStationsButton()

        XCTAssertTrue(mockViewModel.didCallSwap)
        
    }
    
    func test_registersObserver_appBecomeActive_onViewWillAppear() {
        mockNotificationCenter.didCallRemove = false
        mockNotificationCenter.didCallAdd = false
        sut.loadView()
        sut.viewWillAppear(true)
        
        XCTAssertTrue(mockNotificationCenter.didCallAdd)
        XCTAssertFalse(mockNotificationCenter.didCallRemove)
    }
    
    func test_removesObserver_appBecomeActive_onViewWillDisappear() {
        mockNotificationCenter.didCallRemove = false
        mockNotificationCenter.didCallAdd = false
        sut.loadView()
        sut.viewWillDisappear(true)
        
        XCTAssertFalse(mockNotificationCenter.didCallAdd)
        XCTAssertTrue(mockNotificationCenter.didCallRemove)
    }
}




