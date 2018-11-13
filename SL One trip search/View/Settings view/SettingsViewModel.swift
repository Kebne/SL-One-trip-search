//
//  SettingsViewModel.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-13.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

protocol SettingsViewModelType: SettingsViewModelDelegate {
    var originText: String {get}
    var destinationText: String {get}
    var searchTimeFromNow: Float {get}
    var monitorLocation: Bool {get}
    var monitorLocationEnabled: Bool {get}
    var timeSliderEnabled: Bool {get}
    var timeUnit: String {get}
    var renderCallback: (()->Void)? {get set}
    func sliderValueChanged(to: Float)
    func didSwitchRegionSwitch(to: Bool)
    var delegate: SettingsViewModelDelegate? {get set}
}

protocol SettingsViewModelDelegate : AnyObject {
    func didTapStartTextField()
    func didTapDestinationTextField()
}

class SettingsViewModel : SettingsViewModelType {
    
    weak var delegate: SettingsViewModelDelegate?
    
    var originText: String {
        return stateController.userJourneyController.start?.name ?? stateController.userJourneyController.userJourney?.start.name ?? ""
    }
    var destinationText: String {
        return stateController.userJourneyController.destination?.name ?? stateController.userJourneyController.userJourney?.destination.name ?? ""
    }
    var searchTimeFromNow: Float {
        return Float(stateController.userJourneyController.userJourney?.minutesUntilSearch ?? 0)
    }
    var monitorLocation: Bool {
        guard let userJourney = stateController.userJourneyController.userJourney else {return false}
        return userJourney.monitorStationProximity
    }
    var monitorLocationEnabled: Bool {
        return stateController.userJourneyController.userJourney != nil
    }
    var timeSliderEnabled: Bool {
        return stateController.userJourneyController.userJourney != nil
    }
    var timeUnit: String {
        guard let userJourney = stateController.userJourneyController.userJourney else {return ""}
        return userJourney.minutesUntilSearch == 1 ? "minut." : "minuter."
    }
    private var stateController: StateControllerProtocol
    
    var renderCallback: (()->Void)?
    
    init(stateController: StateControllerProtocol) {
        self.stateController = stateController
    }
    
    //MARK: Action
    
    func sliderValueChanged(to: Float) {
        stateController.userJourneyController.timeFromNowUntilSearch = Int(to)
        notifyRenderCallback()
    }
    
    func didSwitchRegionSwitch(to: Bool) {
        stateController.monitorStations(enable: to) {[weak self] success in
            self?.notifyRenderCallback()
        }
    }
    
    func didTapStartTextField() {
        delegate?.didTapStartTextField()
    }
    func didTapDestinationTextField() {
        delegate?.didTapDestinationTextField()
    }
    
    private func notifyRenderCallback() {
        if Thread.current == Thread.main {
            renderCallback?()
        } else {
            DispatchQueue.main.async {[weak self] in
                self?.renderCallback?()
            }
        }
    }
}
