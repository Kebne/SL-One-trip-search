//
//  NotificationService.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-01.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
import UserNotifications

extension UNNotification {
    static let userInfoKeyTrips = "userInfoKeytrips"
    static let userInfoKeySortedCategories = "userInfoKeySortedCategories"
    static let userInfoKeyJourney = "userInfoKeyjourney"
}

protocol UserNotificationCenter {
    func fetchNotificationSettings(completionHandler: @escaping (UserNotificationSettings) -> Void)
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)
    func setNotificationCategories(_ categories: Set<UNNotificationCategory>)
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
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

class NotificationService : NSObject{
    
    private var authCallback: AuthorizationCallback?
    private let notificationCenter: UserNotificationCenter
    
    init(notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current()) {
        self.notificationCenter = notificationCenter
        super.init()
        registerNotificationCategory()
    }
    
    private func registerNotificationCategory() {
        let category = UNNotificationCategory(identifier: NotificationService.notificationCategoryIdentifier, actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: [])
        notificationCenter.setNotificationCategories([category])
    }
    
    // MARK: Authorization
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
    
    private func getNotificationSettings(with completion: @escaping (UserNotificationSettings) -> Void) {
        notificationCenter.fetchNotificationSettings(completionHandler: completion)
    }
    
    private func continueAuth(with completion: @escaping AuthorizationCallback) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationCenter.requestAuthorization(options: authOptions, completionHandler: {[weak self](granted, _) in
            self?.registerNotificationCategory()
            completion(granted)
        })
    }
    
    // MARK: Send notification
    
    func notify(trips: [Trip], userJourney: UserJourney) {

        let content = UNMutableNotificationContent()
        content.categoryIdentifier = NotificationService.notificationCategoryIdentifier
        content.title = notificationTitle(from: userJourney)
        content.sound = UNNotificationSound.default
        
        if #available(iOS 12.1, *) {
            content.body = Strings.defaultBody
        } else {
            content.body = buildNotificationString(from: trips)
        }
        
        sendLocal(notification: content)
    }
    
    private func sendLocal(notification: UNMutableNotificationContent) {
        getNotificationSettings(with: {[weak self](settings) in

            guard let self = self else {return}
            guard settings.authorizationStatus == .authorized else {return}
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0,
                                                            repeats: false)
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: notification, trigger: trigger)
            self.notificationCenter.add(request, withCompletionHandler: nil)
        })
    }
    
    //MARK: Notification content
    
    private func notificationTitle(from userJourney: UserJourney) ->String {
        let introString = userJourney.minutesUntilSearch == 0 ? Strings.titleTripsNow : String(format: Strings.titleTripsInMinutes, userJourney.minutesUntilSearch)
        return String(format: Strings.title, introString,userJourney.start.name,userJourney.destination.name)
    }
    
    private func buildNotificationString(from trips: [Trip]) ->String {
        let sortedTrips = Trip.sortInCategories(trips: trips)
        var string = ""
        
        for category in sortedTrips.sortedKeys {
            string = string + category.description.uppercased() + ":"
            let tripsForCategory = sortedTrips.dictionary[category]!
            for trip in tripsForCategory {
                guard let firstLeg = trip.legList.first else {continue}
                string = string + firstLeg.description
            }
            
            string = string + "\n"
        }
        
        return string
    }
}

extension NotificationService {
    enum Strings {
        static let defaultBody = NSLocalizedString("notification.body.showInstructions", comment: "")
        static let titleTripsNow = NSLocalizedString("notification.title.tripsNow", comment: "")
        static let titleTripsInMinutes = NSLocalizedString("notification.title.tripsInMinutes", comment: "")
        static let title = NSLocalizedString("notification.title", comment: "")
    }
    static let notificationCategoryIdentifier = "journeyNotification"
    typealias AuthorizationCallback = (Bool)->Void
}
