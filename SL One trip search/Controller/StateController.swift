//
//  StateController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit
import CoreLocation

protocol StateControllerProtocol {
    var userJourneyController: UserJourneyControllerProtocol {get set}
    func fetchTrips(completion: @escaping (Result<SLJourneyPlanAPIResponse>)->Void, usingLocation: Bool)
    func monitorStations(enable: Bool, completion: @escaping (Bool)->Void)
    
    init(userController: UserJourneyControllerProtocol, journeyPlannerService: SearchService<SLJourneyPlanAPIResponse>, locationService: LocationService,
         notificationService: NotificationService)
}

class StateController: StateControllerProtocol {
    private let journeyPlannerService: SearchService<SLJourneyPlanAPIResponse>
    private let locationService: LocationService
    private let notificationService: NotificationService
  
    required init(userController: UserJourneyControllerProtocol, journeyPlannerService: SearchService<SLJourneyPlanAPIResponse>, locationService: LocationService,
                  notificationService: NotificationService) {
        self.userJourneyController = userController
        self.journeyPlannerService = journeyPlannerService
        self.locationService = locationService
        self.notificationService = notificationService
        locationService.registerRegion(observer: self)
    }
    
    func fetchTrips(completion: @escaping (Result<SLJourneyPlanAPIResponse>) -> Void, usingLocation: Bool = false) {

        userJourneyController.attemptToRetreiveStoredJourney()
        guard let userJourney = userJourneyController.userJourney else {
            completion(Result.failure(JourneyError.noSettingsAvailable))
            return
        }

        if userJourney.monitorStationProximity && usingLocation {
            locationService.locateUserPosition(callback: {[weak self] result in
                guard let self = self else {return}
                switch result {
                case .success(let position):
                    self.continueSearch(userJourney: self.updateUserJourneyStartNearest(position: position, currentJourney: userJourney), completion: completion)
                default: self.continueSearch(userJourney: userJourney, completion: completion)
                }
            })
        } else {
            continueSearch(userJourney: userJourney, completion: completion)
        }
    }
    
    private func updateUserJourneyStartNearest(position: CLLocationCoordinate2D, currentJourney: UserJourney) ->UserJourney {
        let startCoord = CLLocationCoordinate2D(latitude: currentJourney.start.lat, longitude: currentJourney.start.long)
        let destCoord = CLLocationCoordinate2D(latitude: currentJourney.destination.lat, longitude: currentJourney.destination.long)
        if locationService.distanceBetween(firstLocation: position, secondLocation: destCoord) <
            locationService.distanceBetween(firstLocation: position, secondLocation: startCoord) {
            userJourneyController.swapStations()
        }
        
        return userJourneyController.userJourney!
    }
    
    private func continueSearch(userJourney: UserJourney, completion: @escaping (Result<SLJourneyPlanAPIResponse>) -> Void, persistKey: String? = nil) {
        guard let searchJourneyRequest = JourneySearchRequest(originId: userJourney.start.id,
                                                              destinationId: userJourney.destination.id,
                                                              minutesFromNow: userJourney.minutesUntilSearch) else {
                                                                completion(Result.failure(JourneyError.unableToConstructRequest))
                                                                return
        }
        journeyPlannerService.searchWith(request: searchJourneyRequest, callback: completion, persistDataWithKey: persistKey)
    }
    
    func monitorStations(enable: Bool, completion: @escaping (Bool) -> Void) {
        userJourneyController.monitorStations(enable: enable) {[weak self] success in
            if enable && success {
                self?.requestAuthForNotification(with: completion)
            } else {
                completion(false)
            }
        }
    }
    
    private func requestAuthForNotification(with completion: @escaping (Bool)->Void) {
        notificationService.requestAuthForNotifications(completion: {[weak self] success in
            self?.userJourneyController.monitorStationProximity = success
            completion(success)
        })
    }
    
    func testLocalNotification() {
        guard let journey = userJourneyController.userJourney else {return}
        didEnter(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: journey.start.lat, longitude: journey.start.long), radius: 200.0, identifier: journey.start.id))
    }

    var userJourneyController: UserJourneyControllerProtocol
}


extension StateController : RegionObserver {
    func didEnter(region: CLCircularRegion) {
        guard let currentJourney = userJourneyController.userJourney else {return}
        let updatedUserJourney = updateUserJourneyStartNearest(position: region.center, currentJourney: currentJourney)
        continueSearch(userJourney: updatedUserJourney,completion: {[weak self] result in
            
            if case .success(let response) = result {
                self?.notificationService.notify(trips: response.trips, userJourney: updatedUserJourney)
            }
        }, persistKey: Trip.PersistKey.trip)
    }

}
