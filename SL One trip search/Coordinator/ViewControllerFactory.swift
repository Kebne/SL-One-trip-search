//
//  ViewControllerFactory.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
import UIKit

protocol StoryboardInstantiable {
    static var storyboardIdentifier: String {get}
}

extension StoryboardInstantiable where Self: UIViewController {
    static var storyboardIdentifier : String {
        return String(describing: Self.self)
    }
}

protocol ViewControllerFactory {
    
    func instantiateViewController<T: StoryboardInstantiable>() ->T
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
    
    func instantiateViewController<T: StoryboardInstantiable>() ->T {
        guard let viewController = storyboard.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Unable to instantiate view controller. Make sure that the Storyboard identifier is equal to the class name")
        }
        
        return viewController
    }
}

extension UIStoryboard {
    
    static var main : UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}
