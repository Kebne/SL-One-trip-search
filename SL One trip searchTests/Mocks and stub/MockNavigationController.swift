//
//  MockNavigationController.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit
@testable import SL_One_trip_search

class MockNavigationController : OneTripNavigationController {
    
    var viewControllers = [UIViewController]()
    var didCallPop = false
    
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewControllers.append(viewController)
    }
    
    var topViewController: UIViewController?
    
    func popViewController(animated: Bool) -> UIViewController? {
        didCallPop = true
        return nil
    } 
}
