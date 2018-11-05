//
//  MockUserDefaults.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
@testable import SL_One_trip_search

class MockUserDefaults : UserDefaultProtocol {
    
    var didCallSet = false
    
    func data(forKey: String) -> Data? {
        return try? JSONEncoder().encode(StubGenerator.userJourney)
    }
    
    func set(_ value: Any?, forKey: String) {
        didCallSet = true
    }
    
}
