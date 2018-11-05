//
//  MockPersistService.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
@testable import SL_One_trip_search

class MockPersistService : PersistServiceProtocol {
    
    var didCallRetreive = false
    
    func persist<T>(value: T, forKey key: String) where T : Encodable {
        
    }
    
    func retreive<T>(_ type: T.Type, valueForKey key: String) -> T? where T : Decodable {
        didCallRetreive = true
        return nil
    }
    
    required init(_ userDefaults: UserDefaultProtocol) {
        
    } 
}
