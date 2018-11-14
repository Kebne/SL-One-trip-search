//
//  MockWindow.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
@testable import SL_One_trip_search

class MockWindow : OneTripWindow {
    
    var didSetRootVC = false
    var didCallMakeKey = false
    
    var rootVC: OneTripNavigationController? {
        didSet {
            didSetRootVC = true
        }
    }
    
    func makeKeyAndVisible() {
        didCallMakeKey = true
    }
    
    
}
