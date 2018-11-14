//
//  MockLocationManager.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
import CoreLocation
@testable import SL_One_trip_search

class MockLocationManager : LocationManager {
    
    static var authStatus: CLAuthorizationStatus = .notDetermined
    var authStatusToSet: CLAuthorizationStatus = .denied
    
    static func authorizationStatus() -> CLAuthorizationStatus {
        return authStatus
    }
    
    static func isMonitoringAvailable(for regionClass: AnyClass) -> Bool {
        return true
    }
    
    func startMonitoring(for region: CLRegion) {
        monitoredRegions.insert(region)
    }
    
    func stopMonitoring(for region: CLRegion) {
        monitoredRegions.remove(region)
    }
    
    func requestAlwaysAuthorization() {
        guard let delegate = delegate else {return}
        delegate.locationManager!(CLLocationManager(), didChangeAuthorization: authStatusToSet)
    }
    
    func notifyDelegateDidEnter(region: CLCircularRegion) {
        delegate?.locationManager!(CLLocationManager(), didEnterRegion: region)
    }
    
    var monitoredRegions = Set<CLRegion>()
    
    var delegate: CLLocationManagerDelegate?
    
    func requestLocation() {
        
    }
    
    
}
