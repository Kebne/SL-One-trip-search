//
//  MainCoordinator.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

class MainCoordinator {
    
    private let stateController: StateControllerProtocol
    private let window: UIWindow
    private let viewControllerFactory: ViewControllerFactory
    private let rootNavigationController: UINavigationController
    
    init(stateController: StateControllerProtocol, window: UIWindow, viewControllerFactory: ViewControllerFactory, rootNavigationController: UINavigationController) {
        self.stateController = stateController
        self.window = window
        self.viewControllerFactory = viewControllerFactory
        self.rootNavigationController = rootNavigationController
    }
    
    func start() {
        
        let journeyViewController = viewControllerFactory.journeyViewController
        // Later on we will set a state controller on this
        rootNavigationController.pushViewController(viewControllerFactory.journeyViewController, animated: false)
        
        if stateController.userJourneyController.userJourney == nil {
            let settingsViewController = viewControllerFactory.settingsViewController
            settingsViewController.stateController = self.stateController
            rootNavigationController.pushViewController(settingsViewController, animated: false)
        }
        
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
        
    }

}
