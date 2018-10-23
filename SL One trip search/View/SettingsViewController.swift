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
    var stateController: StateControllerProtocol!
    
    var viewModel = ViewModel() {
        didSet {
            originTextField.text = viewModel.originText
            destinationTextField.text = viewModel.destinationText
            timeFromNowLabel.text = "\(Int(viewModel.searchTimeFromNow))"
            timeSlider.value = viewModel.searchTimeFromNow
            monitorSwitch.isOn = viewModel.monitorLocation
            monitorSwitch.isEnabled = viewModel.monitorLocationEnabled
            timeSlider.isEnabled = viewModel.timeSliderEnabled
            timeUnitLabel.text = viewModel.timeUnit
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        originTextField.delegate = self
        destinationTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        render()
    }
    
    private func render() {
        viewModel = ViewModel(userJourney: stateController.userJourneyController.userJourney,
                              tempStart: stateController.userJourneyController.start,
                              tempDestination: stateController.userJourneyController.destination)
    }
    
    //MARK: Action
    
    @IBAction func sliderDidChangeValue(_ sender: UISlider) {
        stateController.userJourneyController.timeFromNowUntilSearch = Int(sender.value)
        render()
        
    }
    
    @IBAction func didSwitchRegionSwitch(_ sender: UISwitch) {
        
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
    struct ViewModel {
        let originText: String
        let destinationText: String
        let searchTimeFromNow: Float
        let monitorLocation: Bool
        let monitorLocationEnabled: Bool
        let timeSliderEnabled: Bool
        let timeUnit: String
        
        init() {
            originText = ""
            destinationText = ""
            searchTimeFromNow = 0.0
            monitorLocation = false
            monitorLocationEnabled = false
            timeSliderEnabled = false
            timeUnit = "minuter."
        }
        
        init(userJourney: UserJourney?, tempStart: Station?, tempDestination: Station?) {
            originText = tempStart?.name ?? userJourney?.start.name ?? ""
            destinationText = tempDestination?.name ?? userJourney?.destination.name ?? ""
            searchTimeFromNow = Float(userJourney?.minutesUntilSearch ?? 0)
            monitorLocation = Bool(userJourney?.monitorStationProximity ?? false)
            timeSliderEnabled = userJourney == nil ? false : true
            monitorLocationEnabled = userJourney == nil ? false : true
            timeUnit = searchTimeFromNow == 1.0 ? "minut." : "minuter."
            
        }
    }
}
