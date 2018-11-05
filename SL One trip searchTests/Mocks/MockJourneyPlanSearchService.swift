//
//  MockJourneyPlanSearchService.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
@testable import SL_One_trip_search

class MockJourneyPlanSearchService : SearchService<SLJourneyPlanAPIResponse> {
    
    var didCallSearch = false
    var persistDataKey: String?
    var callbackWithSuccess = true
    
    override func searchWith(request: SearchRequest, callback: @escaping (Result<SLJourneyPlanAPIResponse>) -> Void, persistDataWithKey persistKey: String?) {
        didCallSearch = true
        persistDataKey = persistKey
        if callbackWithSuccess {
            callback(Result.success(StubGenerator.slJourneyAPIResponse))
        } else {
            callback(Result.failure(EndpointError.corruptUrlError))
        }
    }
}
