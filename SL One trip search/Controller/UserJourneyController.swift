//
//  UserController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit
import CoreLocation

protocol UserJourneyControllerProtocol {
    func attemptToRetreiveStoredJourney()
    var userJourney: UserJourney? {get}
    var start: Station? {get set}
    var destination: Station? {get set}
    var timeFromNowUntilSearch: Int {get set}
    var monitorStationProximity: Bool {get set}
    func swapStations()
    func monitorStations(enable: Bool, completion: @escaping (Bool)->Void)
}

class UserJourneyController: UserJourneyControllerProtocol {
    
    var userJourney: UserJourney?
    private let persistService: PersistServiceProtocol
    private let userJourneyPersistKey = "userJourneyPersistKey"
    private let locationService: LocationService
    
    init(persistService: PersistServiceProtocol, locationService: LocationService) {
        self.persistService = persistService
        self.locationService = locationService
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
        locationService.stopMonitoring(regions: userJourneyToCLRegions())
        userJourney = UserJourney(start: start, destination: destination, minutesUntilSearch: timeUntilSearch, monitorStationProximity: monitorStationProximity)
        if locationService.locationServicesIsAuthorized() && locationService.monitoringIsAvailable() && monitorStationProximity {
            locationService.monitor(regions: userJourneyToCLRegions())
        }
        persistService.persist(value: userJourney!, forKey: userJourneyPersistKey)
    }
    
    //MARK: Location
    private func stationMonitoringFinishedEnabling(with result: Bool, completion: @escaping (Bool)->Void) {
        monitorStationProximity = result
        completion(result)
    }
    
    private func userJourneyToCLRegions() ->[CLCircularRegion] {
        
        guard let userJourney = userJourney else {
            return [CLCircularRegion]()
        }
        return [locationService.createRegionWith(centerLat: userJourney.start.lat, centerLong: userJourney.start.long, radius: 200.0, identifier: userJourney.start.id),
                locationService.createRegionWith(centerLat: userJourney.destination.lat, centerLong: userJourney.destination.long, radius: 200.0, identifier: userJourney.destination.id)]
    }
    
    //MARK: Public
    
    func monitorStations(enable: Bool, completion: @escaping (Bool)->Void) {
        
        if !enable {
            locationService.stopMonitoring(regions: userJourneyToCLRegions())
        } else if locationService.locationServicesIsAuthorized() && locationService.monitoringIsAvailable() {
            locationService.monitor(regions: userJourneyToCLRegions())
            stationMonitoringFinishedEnabling(with: true, completion: completion)
        } else if !locationService.locationServicesIsAuthorized() && locationService.monitoringIsAvailable() {
            locationService.requestAuthForLocationServices(callback: {[weak self] success in
                guard let self = self else {return}
                self.stationMonitoringFinishedEnabling(with: success, completion: completion)
            })
        } else {
            stationMonitoringFinishedEnabling(with: false, completion: completion)
        }
    }
    
    
    
    
    func swapStations() {
        if let current = userJourney {
            createUserJourney(start: current.destination, destination: current.start, timeUntilSearch: current.minutesUntilSearch, monitorStationProximity: current.monitorStationProximity)
        }
    }
    
}
