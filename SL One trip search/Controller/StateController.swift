//
//  StateController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

protocol StateControllerProtocol {
    var userJourneyController: UserJourneyControllerProtocol {get set}
    func fetchTrips(completion: @escaping (Result<SLJourneyPlanAPIResponse>)->Void)
    
    init(userController: UserJourneyControllerProtocol, journeyPlannerService: SearchService<SLJourneyPlanAPIResponse>)
}

class StateController: StateControllerProtocol {
    private let journeyPlannerService: SearchService<SLJourneyPlanAPIResponse>
    
    required init(userController: UserJourneyControllerProtocol, journeyPlannerService: SearchService<SLJourneyPlanAPIResponse>) {
        self.userJourneyController = userController
        self.journeyPlannerService = journeyPlannerService
    }
    
    func fetchTrips(completion: @escaping (Result<SLJourneyPlanAPIResponse>) -> Void) {
        guard let userJourney = userJourneyController.userJourney else {
            completion(Result.failure(JourneyError.noSettingsAvailable))
            return
        }
        
        guard let searchJourneyRequest = JourneySearchRequest(originId: userJourney.start.id,
                                                        destinationId: userJourney.destination.id,
                                                        minutesFromNow: userJourney.minutesUntilSearch) else {
            completion(Result.failure(JourneyError.unableToConstructRequest))
            return
        }
        
        journeyPlannerService.searchWith(request: searchJourneyRequest, callback: completion)
    }
    
    var userJourneyController: UserJourneyControllerProtocol
}
