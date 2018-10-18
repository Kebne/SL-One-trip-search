//
//  UserController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

protocol UserJourneyControllerProtocol {
    var userJourney: UserJourney? {get}
    var start: Station? {get set}
    var destination: Station? {get set}
    var timeFromNowUntilSearch: Int {get set}
}

class UserJourneyController: UserJourneyControllerProtocol {
    
    var userJourney: UserJourney?
    
    var start: Station? {
        didSet {
            guard let start = start else {
                return
            }
            if let existingJourney = userJourney {
                createUserJourney(start: start, destination: existingJourney.destination, timeUntilSearch: existingJourney.minutesUntilSearch, monitorStationProximity: existingJourney.monitorStationProximity)
            } else {
                createUserJourney()
            }
        }
    }
    var destination: Station?{
        didSet {
            guard let destination = destination else {
                return
            }
            if let existingJourney = userJourney {
                createUserJourney(start: existingJourney.start, destination: destination, timeUntilSearch: existingJourney.minutesUntilSearch, monitorStationProximity: existingJourney.monitorStationProximity)
            } else {
                createUserJourney()
            }
        }
    }
    var timeFromNowUntilSearch: Int = 0 {
        didSet {
            guard let existingJourney = userJourney else {
                return
            }
            createUserJourney(start: existingJourney.start, destination: existingJourney.destination, timeUntilSearch: timeFromNowUntilSearch, monitorStationProximity: existingJourney.monitorStationProximity)
        }
    }
    var monitorStationProximity: Bool = false {
        didSet {
            guard let existingJourney = userJourney else {
                return
            }
            createUserJourney(start: existingJourney.start, destination: existingJourney.destination, timeUntilSearch: existingJourney.minutesUntilSearch, monitorStationProximity: monitorStationProximity)
        }
    }

    private func createUserJourney() {
        guard let start = start, let destination = destination else {
            return
        }
        
        createUserJourney(start: start, destination: destination, timeUntilSearch: timeFromNowUntilSearch, monitorStationProximity: monitorStationProximity)

    }
    
    private func createUserJourney(start: Station, destination: Station, timeUntilSearch: Int, monitorStationProximity: Bool) {
        userJourney = UserJourney(start: start, destination: destination, minutesUntilSearch: timeUntilSearch, monitorStationProximity: monitorStationProximity)
    }
    
    
}
