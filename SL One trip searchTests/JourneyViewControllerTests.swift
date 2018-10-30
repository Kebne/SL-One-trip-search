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

class MockNotificationCenter : NotificationCenterProtocol {
    var didCallAdd = false
    var didCallRemove = false
    func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        didCallAdd = true
    }
    
    func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
        didCallRemove = true
    }
    
    
}

class MockJourneyViewModel : JourneyPresentable {
    var latestSearchString: String = ""
    
    var didCallSwap = false
    var didCallViewDidAppear = false
    var start: String = ""
    
    var destination: String = ""
    
    var timeString: String = ""
    
    var showActivityIndicator: Bool = false
    
    var newJourneyClosure: (() -> Void)?
    
    var nrOfSections: Int = 0
    
    func cellModelFor(indexPath: IndexPath) -> JourneyTableViewCell.ViewModel {
        return JourneyTableViewCell.ViewModel()
    }
    
    func nrOfRowsIn(section: Int) -> Int {
        return 0
    }
    
    func titleFor(section: Int) -> String? {
        return nil
    }
    
    func refreshControlDidRefresh() {
        
    }
    
    func didPressSwapButton() {
        didCallSwap = true
    }
    
    func viewWillAppear() {
        didCallViewDidAppear = true
    }
    
    
}
