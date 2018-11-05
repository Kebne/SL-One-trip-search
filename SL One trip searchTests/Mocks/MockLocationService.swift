//
//  MockLocationService.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
import CoreLocation
@testable import SL_One_trip_search

class PartialMockLocationService : LocationService {
    var didRegisterRegionObserver = false
    override func registerRegion(observer: RegionObserver) {
        didRegisterRegionObserver = true
        super.registerRegion(observer: observer)
    }
    
    override func locationServicesIsAuthorized() -> Bool {
        return MockLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    override func monitoringIsAvailable() -> Bool {
        return MockLocationManager.isMonitoringAvailable(for: CLCircularRegion.classForCoder())
    }
}
