//
//  PersistServiceTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-19.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
@testable import SL_One_trip_search

class PersistServiceTests: XCTestCase {
    
    var sut: PersistService!
    var mockUserDefaults: MockUserDefaults!

    override func setUp() {
        mockUserDefaults = MockUserDefaults()
        sut = PersistService(mockUserDefaults)
    }

    override func tearDown() {
        sut = nil
        mockUserDefaults = nil
    }

    func test_callsSetValue_onPersist() {
        mockUserDefaults.didCallSet = false
        sut.persist(value: PersistStubGenerator.userJourney, forKey: "key")
        XCTAssertTrue(mockUserDefaults.didCallSet)
    }
    
    func test_retreiveUserJourney() {
        let userJourney: UserJourney? = sut.retreive(UserJourney.self, valueForKey: "key")
        XCTAssertNotNil(userJourney)
    }

}


class PersistStubGenerator {
    
    static var userJourney : UserJourney {
        return UserJourney(start: UserJourneyControllerTests.mockStart,
                           destination: UserJourneyControllerTests.mockEnd,
                           minutesUntilSearch: 5, monitorStationProximity: true)
    }
}

class MockUserDefaults : UserDefaultProtocol {
    
    var didCallSet = false
    
    func data(forKey: String) -> Data? {
        return try? JSONEncoder().encode(PersistStubGenerator.userJourney)
    }
    
    func set(_ value: Any?, forKey: String) {
        didCallSet = true
    }

}
