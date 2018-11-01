//
//  LocationServiceTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-31.
//  Copyright © 2018 Kebne. All rights reserved.
//
import XCTest
import CoreLocation
@testable import SL_One_trip_search

class LocationServiceTests: XCTestCase {
    
    var sut: LocationService!
    var mockLocationManager: MockLocationManager!
    
    override func setUp() {
        mockLocationManager = MockLocationManager()
        sut = LocationService(locationManager: mockLocationManager)
    }
    
    override func tearDown() {
        mockLocationManager = nil
        sut = nil
    }
    
    func test_delegateIsSet_onInit() {
        
        XCTAssertNotNil(mockLocationManager.delegate)
    }
    
    func test_callbackWith_false_authorizationDenied_always() {
        MockLocationManager.authStatus = .notDetermined
        mockLocationManager.authStatusToSet = .authorizedWhenInUse
        var authSuccess = true
        sut.requestAuthForLocationServices(callback: {(success) in
            authSuccess = success
        }, alocationManager: MockLocationManager.self)
        
        XCTAssertFalse(authSuccess)
    }
    
    func test_callbackWith_true_authorizationGranted_always() {
        MockLocationManager.authStatus = .notDetermined
        mockLocationManager.authStatusToSet = .authorizedAlways
        var authSuccess = false
        sut.requestAuthForLocationServices(callback: {(success) in
            authSuccess = success
        }, alocationManager: MockLocationManager.self)
        
        XCTAssertTrue(authSuccess)
    }
    
    func test_regionObserver_receivesCallback_enteredRegion() {
        let testRegionObserver = TestRegionObserver()
        sut.registerRegion(observer: testRegionObserver)

        mockLocationManager.notifyDelegateDidEnter(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), radius: 200.0, identifier: "test"))
        
        XCTAssertNotNil(testRegionObserver.enteredRegion)
        
    }
    
}


class TestRegionObserver : RegionObserver {
    var enteredRegion: CLCircularRegion?
    
    func didEnter(region: CLCircularRegion) {
        enteredRegion = region
    }
    
    
}

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
