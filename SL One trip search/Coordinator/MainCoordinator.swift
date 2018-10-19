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
        journeyViewController.delegate = self
        rootNavigationController.pushViewController(journeyViewController, animated: false)

        if stateController.userJourneyController.userJourney == nil {
            showSettings(animated: false)
        }
        
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
        
    }
    
    fileprivate func showSearchViewController(stationJourneyType: StationJourneyType) {
        let stationSearchVC = viewControllerFactory.searchViewController
        stationSearchVC.stationJourneyType = stationJourneyType
        stationSearchVC.stateController = stateController
        stationSearchVC.delegate = self
        rootNavigationController.pushViewController(stationSearchVC, animated: true)
    }
    
    fileprivate func showSettings(animated: Bool = true) {
        let settingsViewController = viewControllerFactory.settingsViewController
        settingsViewController.stateController = self.stateController
        settingsViewController.delegate = self
        rootNavigationController.pushViewController(settingsViewController, animated: animated)
    }

}

extension MainCoordinator : SettingsViewControllerDelegate {
    func didTapStartTextField() {
        showSearchViewController(stationJourneyType: .start)
    }
    
    func didTapDestinationTextField() {
        showSearchViewController(stationJourneyType: .destination)
    }
}

extension MainCoordinator : SearchViewControllerDelegate {
    func didSelectStation() {
        rootNavigationController.popViewController(animated: true)
    }
}

extension MainCoordinator : JourneyViewControllerDelegate {
    func didPressSettings() {
        showSettings()
    }
}
