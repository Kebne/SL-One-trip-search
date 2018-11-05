//
//  MockJourneyViewModel.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
@testable import SL_One_trip_search

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
