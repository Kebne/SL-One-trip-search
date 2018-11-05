//
//  MockNotificationCenter.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
@testable import SL_One_trip_search

class MockNotificationCenter : NotificationCenterProtocol {
    var didCallAdd = false
    var didCallRemove = false
    func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        didCallAdd = true
    }
    
    func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
        didCallRemove = true
    }
    
    
}
