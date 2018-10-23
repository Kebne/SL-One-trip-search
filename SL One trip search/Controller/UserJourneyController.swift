//
//  UserController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

protocol UserJourneyControllerProtocol {
    func attemptToRetreiveStoredJourney()
    var userJourney: UserJourney? {get}
    var start: Station? {get set}
    var destination: Station? {get set}
    var timeFromNowUntilSearch: Int {get set}
    func swapStations()
}

class UserJourneyController: UserJourneyControllerProtocol {
    
    var userJourney: UserJourney?
    private let persistService: PersistServiceProtocol
    private let userJourneyPersistKey = "userJourneyPersistKey"
    
    init(persistService: PersistServiceProtocol) {
        self.persistService = persistService
    }
    
    func attemptToRetreiveStoredJourney() {
        userJourney = persistService.retreive(UserJourney.self, valueForKey: userJourneyPersistKey)
    }
    
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
        persistService.persist(value: userJourney!, forKey: userJourneyPersistKey)
    }
    
    
    //MARK: Public
    
    func swapStations() {
        if let current = userJourney {
            createUserJourney(start: current.destination, destination: current.start, timeUntilSearch: current.minutesUntilSearch, monitorStationProximity: current.monitorStationProximity)
        }
    }
    
}
