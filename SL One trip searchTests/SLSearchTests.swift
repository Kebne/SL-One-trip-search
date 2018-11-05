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
    var mockUserDefaults: MockUserDefaults!

    override func setUp() {
        mockURLSession = MockURLSession()
        mockUserDefaults = MockUserDefaults()
        sut = SearchService<StationSearchResult>(urlSession: mockURLSession, userDefaults: mockUserDefaults)
    }

    override func tearDown() {
        sut = nil
        mockURLSession = nil
        mockUserDefaults = nil
    }
    
    func test_handlesCorrectJSON_callbackWith_StationResult() {
        
        mockURLSession.jsonString = StubGenerator.correctStationJSONString
        mockURLSession.error = nil
        mockURLSession.response200 = true
        
        var response: StationSearchResult? = nil
        
        guard let searchRequest = StationSearchRequest(searchString: "searchString") else {
            XCTFail("Couldn't create search request.")
            return
        }
        sut.searchWith(request: searchRequest, callback: {result in
            
            switch result {
            case .success(let stationRes): response = stationRes
            default:
                XCTFail("Failed to convert correct JSON to Station response.")
            }
            
        })
        XCTAssertNotNil(response)
    }
    
    func test_callsUserDefaults_persistKeyNotNil() {
        mockUserDefaults.didCallSet = false
        mockURLSession.jsonString = StubGenerator.correctStationJSONString
        mockURLSession.error = nil
        mockURLSession.response200 = true
        
        guard let searchRequest = StationSearchRequest(searchString: "searchString") else {
            XCTFail("Couldn't create search request.")
            return
        }
        
        sut.searchWith(request: searchRequest, callback: {(_) in }, persistDataWithKey: "test")
        
        XCTAssertTrue(mockUserDefaults.didCallSet)
        
        
    }
    
    
    func test_handlesCorruptJSON_callbackWith_StationResult() {
        
        mockURLSession.jsonString = StubGenerator.brokenStationJSONString
        mockURLSession.error = nil
        mockURLSession.response200 = true
        
        var response: StationSearchResult? = nil
        var error: Error?
        
        guard let searchRequest = StationSearchRequest(searchString: "searchString") else {
            XCTFail("Couldn't create search request.")
            return
        }
        sut.searchWith(request: searchRequest, callback:  {result in
            
            switch result {
            case .success(let stationRes): response = stationRes
            case.failure(let requestError): error = requestError
            }
            
        })
        XCTAssertNotNil(error)
        XCTAssertNil(response)
    }
    
    func test_errorCallback_httpStatusCode_not200() {
        
        mockURLSession.jsonString = nil
        mockURLSession.error = nil
        mockURLSession.response200 = false
        
        var response: StationSearchResult? = nil
        var error: Error?
        
        guard let searchRequest = StationSearchRequest(searchString: "searchString") else {
            XCTFail("Couldn't create search request.")
            return
        }
        sut.searchWith(request: searchRequest, callback: {result in
            
            switch result {
            case .success(let stationRes): response = stationRes
            case.failure(let requestError): error = requestError
            }
            
        })
        XCTAssertNotNil(error)
        XCTAssertNil(response)
    }
    
    func test_errorCallback_onCompletionError() {
        
        mockURLSession.jsonString = StubGenerator.brokenStationJSONString
        mockURLSession.error = EndpointError.corruptUrlError
        mockURLSession.response200 = true
        
        var response: StationSearchResult? = nil
        var error: Error?
        
        guard let searchRequest = StationSearchRequest(searchString: "searchString") else {
            XCTFail("Couldn't create search request.")
            return
        }
        sut.searchWith(request: searchRequest, callback: {result in
            
            switch result {
            case .success(let stationRes): response = stationRes
            case.failure(let requestError): error = requestError
            }
            
        })
        XCTAssertNotNil(error)
        XCTAssertNil(response)
    }

}


