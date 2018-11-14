//
//  MockUserJourneyController.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
@testable import SL_One_trip_search

class MockUserJourneyController : UserJourneyControllerProtocol {
    func monitorStations(enable: Bool, completion: @escaping (Bool) -> Void) {
        
    }
    
    var monitorStationProximity: Bool = false
    
    var didCallSwapStations = false
    
    func attemptToRetreiveStoredJourney() {
        
    }
    
    var userJourney: UserJourney?
    
    var start: Station?
    
    var destination: Station?
    
    var timeFromNowUntilSearch: Int = 0
    
    func swapStations() {
        didCallSwapStations = true
    }
    
    
}
