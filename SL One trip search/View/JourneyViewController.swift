//
//  ViewController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

protocol JourneyViewControllerDelegate : AnyObject {
    func didPressSettings()
}

class JourneyViewController: UIViewController, StoryboardInstantiable {
    
    weak var delegate: JourneyViewControllerDelegate?
    
    @IBAction func didPressSettingsButton(_ sender: UIBarButtonItem) {
        delegate?.didPressSettings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


}

