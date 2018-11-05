//
//  MockURLSession.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
@testable import SL_One_trip_search

class MockURLSession : URLSessionProtocol {
    
    var response200: Bool = true
    var error: Error?
    var jsonString: String?
    
    func dataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        let statusCode = response200 ? 200 : 400
        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        
        var jsonData: Data? = nil
        if let jsonString = jsonString {
            jsonData = jsonString.data(using: .utf8)
        }
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
