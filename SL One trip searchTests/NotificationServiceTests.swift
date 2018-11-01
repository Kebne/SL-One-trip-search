//
//  NotificationServiceTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-01.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
import UserNotifications
@testable import SL_One_trip_search

class NotificationServiceTests: XCTestCase {
    
    var sut: NotificationService!
    var mockNotificationCenter: MockUserNotificationCenter!

    override func setUp() {
        mockNotificationCenter = MockUserNotificationCenter()
        sut = NotificationService(notificationCenter: mockNotificationCenter)
    }

    override func tearDown() {
        mockNotificationCenter = nil
        sut = nil
    }
    
    
    func test_receivesCallbackFalse_authorizationDenied() {
        mockNotificationCenter.mockNotificationSettings.authorizationStatus = .notDetermined
        mockNotificationCenter.authSuccess = false
        var authSuccess = true
        sut.requestAuthForNotifications(completion: {(success) in
            authSuccess = success
        })
        
        XCTAssertFalse(authSuccess)
        
    }
    
    func test_receivesCallbackTrue_authorizationGranted() {
        mockNotificationCenter.mockNotificationSettings.authorizationStatus = .notDetermined
        mockNotificationCenter.authSuccess = true
        var authSuccess = false
        sut.requestAuthForNotifications(completion: {(success) in
            authSuccess = success
        })
        
        XCTAssertTrue(authSuccess)
    }
    
    func test_receivesCallbackFalse_statusIsDenied() {
        mockNotificationCenter.mockNotificationSettings.authorizationStatus = .denied
        mockNotificationCenter.authSuccess = true
        var authSuccess = true
        sut.requestAuthForNotifications(completion: {(success) in
            authSuccess = success
        })
        
        XCTAssertFalse(authSuccess)
    }

}


class MockUserNotificationCenter : UserNotificationCenter {
    var mockNotificationSettings = MockUserNotificationSettings()
    var authSuccess = true
    var authError: Error?
    func fetchNotificationSettings(completionHandler: @escaping (UserNotificationSettings) -> Void) {
        completionHandler(mockNotificationSettings)
    }
    
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        completionHandler(authSuccess, authError)
    }
}


class MockUserNotificationSettings : UserNotificationSettings {
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
}
