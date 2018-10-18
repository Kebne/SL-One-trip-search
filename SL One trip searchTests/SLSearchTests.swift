//
//  SLSearchTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-18.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest

@testable import SL_One_trip_search

class SLSearchTests: XCTestCase {
    
    var sut: SearchService<StationSearchResult>!
    var mockURLSession: MockURLSession!

    override func setUp() {
        mockURLSession = MockURLSession()
        sut = SearchService<StationSearchResult>(urlSession: mockURLSession)
    }

    override func tearDown() {
        sut = nil
        mockURLSession = nil
    }
    
    func test_handlesCorrectJSON_callbackWith_StationResult() {
        
        mockURLSession.correctJson = true
        mockURLSession.error = nil
        mockURLSession.response200 = true
        
        var response: StationSearchResult? = nil
        
        guard let searchRequest = StationSearchRequest(searchString: "searchString") else {
            XCTFail("Couldn't create search request.")
            return
        }
        sut.searchWith(request: searchRequest) {result in
            
            switch result {
            case .success(let stationRes): response = stationRes
            default:
                XCTFail("Failed to convert correct JSON to Station response.")
            }
            
        }
        XCTAssertNotNil(response)
    }

}

class MockURLSession : URLSessionProtocol {

    var correctJson: Bool = true
    var response200: Bool = true
    var error: Error?

    func dataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        let statusCode = response200 ? 200 : 400
        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        
        let jsonData = correctJson ? StubGenerator.correctStationJSONString.data(using: .utf8) : StubGenerator.brokenStationJSONString.data(using: .utf8)
        completion(jsonData, urlResponse, error)
        
        
        return MockURLSessionDataTask()
    }
}

class MockURLSessionDataTask : URLSessionDataTaskProtocol {
    
    var didCallResume: Bool = false
    func resume() {
        didCallResume = true
    }
}

class StubGenerator {
    
    static var correctStationJSONString : String {
        return """
        { "StatusCode": 0, "Message": null, "ExecutionTime": 0, "ResponseData": [
        { "Name": "Slussen (Stockholm)", "SiteId": "9192", "Type": "Station", "X": "18071860", "Y": "59320284" },
        { "Name": "Slumnäsvägen (Tyresö)", "SiteId": "8056", "Type": "Station", "X": "18273946", "Y": "59248604" } ]}
"""
    }
    
    static var brokenStationJSONString : String {
        return """
        { "StatusCode": 0, "Message": null, "ExecutionTime": 0, "ResponseData": [
        { "Name": "Slussen (Stockholm)", "SiteId": "9192", "Type": "Station", "X": "18071860", "Y": "59320284" },
        { "Name": "Slumnäsvägen (Tyresö)", "SiteId": "8056", "Type": "Station", "X": "18273946", "Y": "59248604" }
        """
    }
    
}
