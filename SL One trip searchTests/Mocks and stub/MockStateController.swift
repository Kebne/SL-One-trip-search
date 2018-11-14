//
//  MockStateController.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
@testable import SL_One_trip_search
class MockStateController : StateControllerProtocol {
    
    func monitorStations(enable: Bool, completion: @escaping (Bool) -> Void) {
        
    }
    
    required init(userController: UserJourneyControllerProtocol, journeyPlannerService: SearchService<SLJourneyPlanAPIResponse>, locationService: LocationService, notificationService: NotificationService) {
        userJourneyController = userController
    }
    
    var userJourneyController: UserJourneyControllerProtocol
    var jsonString: String?
    
    func fetchTrips(completion: @escaping (Result<SLJourneyPlanAPIResponse>) -> Void, usingLocation: Bool) {
        if let string = jsonString,  let jsonData = string.data(using: .utf8) {
            do {
                let result = try JSONDecoder().decode(SLJourneyPlanAPIResponse.self, from: jsonData)
                completion(Result.success(result))
            } catch let e {
                completion(Result.failure(e))
            }
        }
        
        completion(Result.failure(EndpointError.corruptData))
    }
}
