//
//  ViewControllerFactory.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    static var viewControllerName: String {
        return String(describing: self)
    }
}

protocol ViewControllerFactory {
    
    var journeyViewController: JourneyViewController {get}
    var settingsViewController: SettingsViewController {get}
    var searchViewController: SearchViewController {get}
    func createSimpleAlert(withTitle title: String, message: String) -> UIAlertController
    func createTextFieldAlert(withTitle title: String, message: String,okTitle: String, cancelTitle: String, placeholder: String, completionHandler: @escaping (String?)->()) ->UIAlertController
}

class ViewControllerFactoryClass : ViewControllerFactory {
    func createSimpleAlert(withTitle title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alertController
    }
    
    func createTextFieldAlert(withTitle title: String, message: String,okTitle: String, cancelTitle: String, placeholder: String, completionHandler: @escaping (String?)->()) ->UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = placeholder
        }
        let okAction = UIAlertAction(title: okTitle, style: .cancel, handler: {(action) in
            completionHandler(alertController.textFields?.first?.text)
        })
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default, handler: {(action) in
            completionHandler(nil)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        return alertController
    }
    
    var storyboard: UIStoryboard
    
    init(storyboard: UIStoryboard) {
        self.storyboard = storyboard
    }
    
    
    /// IMPORTANT!!!
    /// When a view controller is added in the Storyboard, it needs to have an identifier that is the same as the class name.
    var journeyViewController: JourneyViewController {
        return storyboard.instantiateViewController(withIdentifier: JourneyViewController.viewControllerName) as! JourneyViewController
    }
    
    var settingsViewController: SettingsViewController {
        return storyboard.instantiateViewController(withIdentifier: SettingsViewController.viewControllerName) as! SettingsViewController
    }
    
    var searchViewController: SearchViewController {
        return storyboard.instantiateViewController(withIdentifier: SearchViewController.viewControllerName) as! SearchViewController
    }
}

extension UIStoryboard {
    
    static var main : UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}
