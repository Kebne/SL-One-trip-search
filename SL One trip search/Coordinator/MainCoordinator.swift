//
//  MainCoordinator.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

protocol OneTripNavigationController {
    func pushViewController(_ viewController: UIViewController, animated: Bool)
    var topViewController: UIViewController? { get }
    func popViewController(animated: Bool) -> UIViewController?
}

protocol OneTripWindow : AnyObject {
    var rootVC: OneTripNavigationController? {get set}
    func makeKeyAndVisible()
}

extension UIWindow : OneTripWindow {
    var rootVC: OneTripNavigationController? {
        get {
            return self.rootViewController as? OneTripNavigationController
        }
        set (newValue) {
            self.rootViewController = newValue as? UIViewController
        }
    }
    
    
}

extension UINavigationController : OneTripNavigationController {}

class MainCoordinator {
    
    private let stateController: StateControllerProtocol
    private let window: OneTripWindow
    private let viewControllerFactory: ViewControllerFactory
    private let rootNavigationController: OneTripNavigationController
    
    init(stateController: StateControllerProtocol, window: OneTripWindow, viewControllerFactory: ViewControllerFactory, rootNavigationController: OneTripNavigationController) {
        self.stateController = stateController
        self.window = window
        self.viewControllerFactory = viewControllerFactory
        self.rootNavigationController = rootNavigationController
    }
    
    func start() {
        
        let journeyViewController: JourneyViewController = viewControllerFactory.instantiateViewController()
        journeyViewController.delegate = self
        journeyViewController.viewModel = JourneyViewModel(stateController: stateController)
        rootNavigationController.pushViewController(journeyViewController, animated: false)


        if stateController.userJourneyController.userJourney == nil {
            showSettings(animated: false)
        }
        
        window.rootVC = rootNavigationController
        window.makeKeyAndVisible()
        
    }
    
    fileprivate func showSearchViewController(stationJourneyType: StationJourneyType) {
        
        let stationSearchVC: SearchViewController = viewControllerFactory.instantiateViewController()
        stationSearchVC.stationJourneyType = stationJourneyType
        stationSearchVC.stateController = stateController
        stationSearchVC.delegate = self
        rootNavigationController.pushViewController(stationSearchVC, animated: true)
    }
    
    fileprivate func showSettings(animated: Bool = true) {
        if let currentController = rootNavigationController.topViewController, currentController is SettingsViewController {
            return
        }
        let settingsViewController: SettingsViewController = viewControllerFactory.instantiateViewController()
        settingsViewController.stateController = self.stateController
        settingsViewController.delegate = self
        rootNavigationController.pushViewController(settingsViewController, animated: animated)
    }
    
    //MARK: Handle URL
    
    func handle(url: URL) ->Bool {
        guard let scheme = url.scheme, scheme == URL.oneTripScheme else {
            return false
        }
        
        guard stateController.userJourneyController.userJourney != nil else {
            showSettings(animated: false)
            return true
        }
        
        if let host = url.host, host == SharedAppConstant.urlPathFrom {
            showSearchViewController(stationJourneyType: .start)
        } else if let host = url.host, host == SharedAppConstant.urlPathDestination {
            showSearchViewController(stationJourneyType: .destination)
        }
        
        return true
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
    
    func didPressEndStationButton() {
        guard stateController.userJourneyController.userJourney != nil else {
            showSettings(animated: true)
            return
        }
        showSearchViewController(stationJourneyType: .destination)
    }
    
    func didPressStartStationButton() {
        guard stateController.userJourneyController.userJourney != nil else {
            showSettings(animated: true)
            return
        }
        showSearchViewController(stationJourneyType: .start)
    }
}
