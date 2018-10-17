//
//  SettingsViewController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var timeFromNowLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var monitorSwitch: UISwitch!
    var stateController: StateControllerProtocol!
    var viewModel = ViewModel() {
        didSet {
            originTextField.text = viewModel.originText
            destinationTextField.text = viewModel.destinationText
            timeFromNowLabel.text = "\(Int(viewModel.searchTimeFromNow))"
            timeSlider.value = viewModel.searchTimeFromNow
            monitorSwitch.isOn = viewModel.monitorLocation
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
        viewModel = ViewModel(user: stateController.userController.user)
    }
    
    //MARK: Action
    
    @IBAction func sliderDidChangeValue(_ sender: UISlider) {
        
        
    }
    
    @IBAction func didSwitchRegionSwitch(_ sender: UISwitch) {
        
    }
    
}

extension SettingsViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Show search view
        return false
    }
}

extension SettingsViewController {
    struct ViewModel {
        let originText: String
        let destinationText: String
        let searchTimeFromNow: Float
        let monitorLocation: Bool
        
        init() {
            originText = ""
            destinationText = ""
            searchTimeFromNow = 0.0
            monitorLocation = false
        }
        
        init(user: User?) {
            originText = user?.start?.name ?? ""
            destinationText = user?.destination?.name ?? ""
            searchTimeFromNow = Float(user?.timeFromNowToSearchForJourney ?? 0.0)
            monitorLocation = Bool(user?.monitorPosition ?? false)
        }
    }
}
