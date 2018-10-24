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

    override func setUp() {
        mockViewModel = MockJourneyViewModel()
        let vcFactory = ViewControllerFactoryClass(storyboard: UIStoryboard.main)
        sut = vcFactory.journeyViewController
        sut.viewModel = mockViewModel
    }

    override func tearDown() {
        mockViewModel = nil
        sut = nil
    }

    func test_callsSwap_onViewModel() {
        
        mockViewModel.didCallSwap = false
        sut.didPressSwapStationsButton()

        XCTAssertTrue(mockViewModel.didCallSwap)
        
    }
}


class MockJourneyViewModel : JourneyPresentable {
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
