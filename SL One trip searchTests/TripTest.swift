//
//  TripTest.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-07.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
@testable import SL_One_trip_search

class TripTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_tripCategorySortFunction() {
        
        let metroLeg = StubGenerator.legWith(originTime: Date(), arrivalTime: Date().addingTimeInterval(10), transportType: TransportType.product(Product(category: .metro, name: "M", line: "1")), hidden: false, id: 0)
        let busLeg = StubGenerator.legWith(originTime: Date(), arrivalTime: Date().addingTimeInterval(20), transportType: TransportType.product(Product(category: .bus, name: "M", line: "1")), hidden: false, id: 1)
        
        let trainLeg = StubGenerator.legWith(originTime: Date(), arrivalTime: Date().addingTimeInterval(5), transportType: TransportType.product(Product(category: .train, name: "M", line: "1")), hidden: false, id: 0)
        let busLeg2 = StubGenerator.legWith(originTime: Date(), arrivalTime: Date().addingTimeInterval(30), transportType: TransportType.product(Product(category: .bus, name: "M", line: "1")), hidden: false, id: 1)
        
        let metro2Leg = StubGenerator.legWith(originTime: Date(), arrivalTime: Date().addingTimeInterval(30), transportType: TransportType.product(Product(category: .metro, name: "M", line: "1")), hidden: false, id: 0)
        let bus2Leg = StubGenerator.legWith(originTime: Date().addingTimeInterval(30), arrivalTime: Date().addingTimeInterval(60), transportType: TransportType.product(Product(category: .bus, name: "M", line: "1")), hidden: false, id: 1)
        
        let metroBusTrip = Trip(legList: [metroLeg, busLeg])
        let metroBusTrip2 = Trip(legList: [metro2Leg, bus2Leg])
        let trainBusTrip = Trip(legList: [trainLeg, busLeg2])
        
        let sortedResults = Trip.sortInCategories(trips: [trainBusTrip, metroBusTrip, metroBusTrip2])
        
        XCTAssertEqual(sortedResults.sortedKeys.count, 2)
        XCTAssertEqual(sortedResults.sortedKeys[0], ProductCategory.metro)
        XCTAssertEqual(sortedResults.sortedKeys[1], ProductCategory.train)
    }

}
