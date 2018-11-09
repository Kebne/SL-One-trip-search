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
        let journeyViewModel = JourneyViewModel(stateController: stateController)
        journeyViewModel.delegate = self
        journeyViewController.viewModel = journeyViewModel
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
        settingsViewController.viewModel = SettingsViewController.ViewModel(stateController: stateController)
        settingsViewController.delegate = self
        rootNavigationController.pushViewController(settingsViewController, animated: animated)
    }
    
    fileprivate func showJourneyDetailView(with trip: Trip) {
        let journeyDetailViewController: JourneyDetailViewController = viewControllerFactory.instantiateViewController()
        let viewModel = JourneyDetailViewModel(trip)
        viewModel.delegate = self
        journeyDetailViewController.viewModel = viewModel
        rootNavigationController.pushViewController(journeyDetailViewController, animated: true)
    }
    
    fileprivate func showMapView(with trip: Trip) {
        let mapViewController: MapViewController = viewControllerFactory.instantiateViewController()
        mapViewController.mapViewModel = MapViewModel(trip: trip)
        rootNavigationController.pushViewController(mapViewController, animated: true)
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
        _ = rootNavigationController.popViewController(animated: true)
    }
}

extension MainCoordinator : JourneyViewModelDelegate {
    func showDetailView(for trip: Trip) {
        showJourneyDetailView(with: trip)
    }
    
    
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

extension MainCoordinator : JourneyDetailViewModelDelegate {
    func showMapView(for trip: Trip) {
        showMapView(with: trip)
    }
    
    
}
