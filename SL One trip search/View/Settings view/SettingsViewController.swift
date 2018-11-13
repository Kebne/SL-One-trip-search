//
//  SettingsViewController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit



class SettingsViewController: UIViewController, StoryboardInstantiable {
    
    
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var timeFromNowLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var monitorSwitch: UISwitch!
    @IBOutlet weak var timeUnitLabel: UILabel!

    var viewModel: SettingsViewModelType!

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
            viewModel.didTapStartTextField()
        } else if textField == destinationTextField {
            viewModel.didTapDestinationTextField()
        }
        return false
    }
}
