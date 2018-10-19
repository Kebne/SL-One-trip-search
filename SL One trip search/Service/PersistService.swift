//
//  PersistService.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-19.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

protocol UserDefaultProtocol {
    func data(forKey: String) ->Data?
    func set(_ value: Any?, forKey: String)
}

extension UserDefaults : UserDefaultProtocol {}

protocol PersistServiceProtocol {
    func persist<T: Encodable>(value: T, forKey key: String)
    func retreive<T: Decodable>(_ type: T.Type, valueForKey key: String) ->T?
    init(_ userDefaults: UserDefaultProtocol)
}

class PersistService : PersistServiceProtocol {
    
    private let userDefaults: UserDefaultProtocol
    required init(_ userDefaults: UserDefaultProtocol = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    func persist<T: Encodable>(value: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            userDefaults.set(encoded, forKey: key)
        }
    }
    
    func retreive<T: Decodable>(_ type: T.Type, valueForKey key: String) ->T? {
        guard let data = userDefaults.data(forKey: key) else {return nil}
        return try? JSONDecoder().decode(type, from: data)
    }
}
