//
//  StationTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-19.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
@testable import SL_One_trip_search

class StationTests: XCTestCase {

    func test_constructsCorrectStation_fromSLStation() {
        
        let expectedArea = "Stockholm"
        let expectedName = "Slussen"
        let expectedLat = 18.071860
        let expectedLong = 59.320284
        let slStationX = "\(expectedLong)".replacingOccurrences(of: ".", with: "")
        let slStationY = "\(expectedLat)".replacingOccurrences(of: ".", with: "")
        let slStationName = expectedName + " (" + expectedArea + ")"
        let id = "id"
        
        let slStation = SLStation(name: slStationName, id: id, x: slStationX, y: slStationY)
        let station = slStation.station
        
        XCTAssertEqual(station.name, expectedName)
        XCTAssertEqual(station.area, expectedArea)
        XCTAssertEqual(station.lat, expectedLat)
        XCTAssertEqual(station.long, expectedLong)
        XCTAssertEqual(station.id, id)
    }

}
