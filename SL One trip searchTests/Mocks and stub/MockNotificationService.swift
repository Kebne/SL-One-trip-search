//
//  MockNotificationService.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
@testable import SL_One_trip_search

class PartialMockNotificationService : NotificationService {
    
    var didCallNotifyTrips = false
    override func notify(trips: [Trip], userJourney: UserJourney) {
        didCallNotifyTrips = true
    }
}
