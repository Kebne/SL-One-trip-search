//
//  LocationService.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-30.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
import CoreLocation
protocol LocationManager : class {
    static func authorizationStatus() -> CLAuthorizationStatus
    static func isMonitoringAvailable(for regionClass: AnyClass) -> Bool
    func startMonitoring(for region: CLRegion)
    func stopMonitoring(for region: CLRegion)
    func requestAlwaysAuthorization()
    var monitoredRegions: Set<CLRegion> { get }
    var delegate: CLLocationManagerDelegate? {get set}
    func requestLocation()
}

enum LocationError : Error {
    case notAuthorized
    case noLocationFound
}

protocol RegionObserver : AnyObject {
    func didEnter(region: CLCircularRegion)
}

extension CLLocationManager : LocationManager {}

class LocationService: NSObject {
    typealias StartRegionMonitorCallback = (Bool)->()
    typealias LocateUserCallback = (Result<CLLocationCoordinate2D>)->()
    private var locationManager: LocationManager
    fileprivate var startMonitoringCallback: StartRegionMonitorCallback?
    fileprivate var locateUserCallback: LocateUserCallback?
    weak var regionObserver: RegionObserver?
    
    required init(locationManager: LocationManager) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
    }

    
    func registerRegion(observer: RegionObserver) {
        regionObserver = observer
    }
    
    func removeRegion(observer: RegionObserver) {
        regionObserver = nil
    }
    
    func requestAuthForLocationServices(callback: @escaping (Bool) -> (), alocationManager: LocationManager.Type = CLLocationManager.self) {
        startMonitoringCallback = callback
        switch alocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            return
        case .denied, .restricted, .authorizedWhenInUse:
            callback(false)
            return
        default:
            break
        }
    }
    
    func monitor(regions: [CLCircularRegion]) {
        guard monitoringIsAvailable() else {return}
        regions.forEach({locationManager.startMonitoring(for: $0)})
    }
    
    func stopMonitoring(regions: [CLCircularRegion]) {
        regions.forEach({locationManager.stopMonitoring(for: $0)})
    }
    
    func monitoringIsAvailable() ->Bool {
        return CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.classForCoder()) && CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    func isMonitoring(region: CLCircularRegion) ->Bool {
        return locationManager.monitoredRegions.contains(region)
    }
    
    func createRegionWith(centerLat: Double, centerLong: Double, radius: Double, identifier: String) ->CLCircularRegion {
        return CLCircularRegion(center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong), radius: radius, identifier: identifier)
    }
    
    func locateUserPosition(callback:@escaping LocateUserCallback) {
        guard monitoringIsAvailable() else {
            callback(Result.failure(LocationError.notAuthorized))
            return
        }
        locateUserCallback = callback
        locationManager.requestLocation()
    }
}

extension LocationService : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let callback = startMonitoringCallback else {return}
        callback(status == .authorizedAlways)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let callback = locateUserCallback else {return}
        guard let location = locations.first else {
            callback(Result.failure(LocationError.noLocationFound))
            return
        }
        callback(Result.success(location.coordinate))
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let observer = regionObserver,
            let circularRegion = region as? CLCircularRegion else {return}
        observer.didEnter(region: circularRegion)
    }
}
