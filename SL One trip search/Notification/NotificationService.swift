//
//  NotificationService.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-01.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
import UserNotifications

protocol UserNotificationCenter {
    func fetchNotificationSettings(completionHandler: @escaping (UserNotificationSettings) -> Void)
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)
}

protocol UserNotificationSettings {
    var authorizationStatus: UNAuthorizationStatus { get }
}

extension UNNotificationSettings : UserNotificationSettings {}

extension UNUserNotificationCenter : UserNotificationCenter {
    func fetchNotificationSettings(completionHandler: @escaping (UserNotificationSettings) -> Void) {
        getNotificationSettings(completionHandler: completionHandler)
    }
}

class NotificationService {
    typealias AuthorizationCallback = (Bool)->Void
    private var authCallback: AuthorizationCallback?
    private let notificationCenter: UserNotificationCenter
    
    init(notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current()) {
        self.notificationCenter = notificationCenter
    }
    
    //MARK: Authorization
    func requestAuthForNotifications(completion: @escaping AuthorizationCallback) {
        getNotificationSettings(with: {[weak self](settings) in
            if settings.authorizationStatus == .notDetermined {
                self?.continueAuth(with: completion)
            } else if settings.authorizationStatus == .denied {
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
    func getNotificationSettings(with completion: @escaping (UserNotificationSettings) -> Void) {
        notificationCenter.fetchNotificationSettings(completionHandler: completion)
    }
    
    private func continueAuth(with completion: @escaping AuthorizationCallback) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationCenter.requestAuthorization(options: authOptions, completionHandler: {(granted, _) in
            completion(granted)
        })
    }
    
    //    MARK: Send notification
    
}
