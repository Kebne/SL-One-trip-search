//
//  MockUserNotificationCenter.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
import UserNotifications
@testable import SL_One_trip_search

class MockUserNotificationCenter : UserNotificationCenter {
    var notificationCategories = Set<UNNotificationCategory>()
    var didCallAddRequest = false
    func setNotificationCategories(_ categories: Set<UNNotificationCategory>) {
        notificationCategories = categories
    }
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        didCallAddRequest = true
    }
    
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
