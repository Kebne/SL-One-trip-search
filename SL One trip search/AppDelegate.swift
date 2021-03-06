//
//  AppDelegate.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainCoordinator: MainCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let userDefaults = UserDefaults(suiteName: "group.container.kebne.slonetripsearch")!
        let persistService = PersistService(userDefaults)
        let locationService = LocationService(locationManager: CLLocationManager())
        let userController = UserJourneyController(persistService: persistService, locationService: locationService)
        userController.attemptToRetreiveStoredJourney()

        let stateController = StateController(userController: userController, journeyPlannerService: SearchService<SLJourneyPlanAPIResponse>(), locationService: locationService, notificationService: NotificationService())
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootNavController = UINavigationController()
        let viewControllerFactory = ViewControllerFactoryClass(storyboard: UIStoryboard.main)
        mainCoordinator = MainCoordinator(stateController: stateController,
                                          window: window!,
                                          viewControllerFactory: viewControllerFactory,
                                          rootNavigationController: rootNavController)
        mainCoordinator.start()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

        return mainCoordinator.handle(url: url)
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

