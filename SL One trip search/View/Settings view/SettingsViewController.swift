//
//  SettingsViewController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate : AnyObject {
    func didTapStartTextField()
    func didTapDestinationTextField()
}

class SettingsViewController: UIViewController, StoryboardInstantiable {
    
    
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var timeFromNowLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var monitorSwitch: UISwitch!
    @IBOutlet weak var timeUnitLabel: UILabel!
    
    weak var delegate: SettingsViewControllerDelegate?
    var viewModel: ViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        originTextField.delegate = self
        destinationTextField.delegate = self
        viewModel.renderCallback = {[weak self] in
            self?.render()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        render()
    }
    
    private func render() {
        originTextField.text = viewModel.originText
        destinationTextField.text = viewModel.destinationText
        timeFromNowLabel.text = "\(Int(viewModel.searchTimeFromNow))"
        timeSlider.value = viewModel.searchTimeFromNow
        monitorSwitch.isOn = viewModel.monitorLocation
        monitorSwitch.isEnabled = viewModel.monitorLocationEnabled
        timeSlider.isEnabled = viewModel.timeSliderEnabled
        timeUnitLabel.text = viewModel.timeUnit
    }
    
    //MARK: Action
    
    @IBAction func sliderDidChangeValue(_ sender: UISlider) {
        viewModel.sliderValueChanged(to: sender.value)
    }
    
    @IBAction func didSwitchRegionSwitch(_ sender: UISwitch) {
        viewModel.didSwitchRegionSwitch(to: sender.isOn)
    }
    
}

extension SettingsViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == originTextField {
            delegate?.didTapStartTextField()
        } else if textField == destinationTextField {
            delegate?.didTapDestinationTextField()
        }
        return false
    }
}

extension SettingsViewController {
    class ViewModel {
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
        
        func sliderValueChanged(to: Float) {
            stateController.userJourneyController.timeFromNowUntilSearch = Int(to)
            notifyRenderCallback()
        }
        
        func didSwitchRegionSwitch(to: Bool) {
            stateController.monitorStations(enable: to) {[weak self] success in
                self?.notifyRenderCallback()
            }
        }
        
        func notifyRenderCallback() {
            if Thread.current == Thread.main {
                renderCallback?()
            } else {
                DispatchQueue.main.async {[weak self] in
                   self?.renderCallback?()
                }
            }
        }
    }
}
