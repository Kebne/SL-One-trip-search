//
//  SLSearch.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-18.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

enum EndpointError : Error {
    case corruptUrlError
    case corruptUrlResponse
    case corruptData
}

enum Result<T> {
    case success(T)
    case failure(Error)
}

protocol SLSearch {
    associatedtype ResultType
    typealias SearchCallback = (Result<ResultType>)->Void
    func searchWith(request: SearchRequest, callback: @escaping SearchCallback, persistDataWithKey key: String?)
    init(urlSession: URLSessionProtocol, userDefaults: UserDefaultProtocol)
}


protocol URLSessionDataTaskProtocol { func resume() }
extension URLSessionDataTask : URLSessionDataTaskProtocol {}

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

extension URLSession : URLSessionProtocol {
    func dataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completion) as URLSessionDataTaskProtocol
    }
}

class SearchService<T: Decodable> : SLSearch {
    private let urlSession: URLSessionProtocol
    private let userDefaults: UserDefaultProtocol
    
    required init(urlSession: URLSessionProtocol = URLSession.shared, userDefaults: UserDefaultProtocol = UserDefaults(suiteName: "group.container.kebne.slonetripsearch") ?? UserDefaults.standard) {
        self.urlSession = urlSession
        self.userDefaults = userDefaults
    }
    
    func searchWith(request: SearchRequest, callback: @escaping (Result<T>) -> Void, persistDataWithKey persistKey: String? = nil) {
        var urlrequest = URLRequest(url: request.url)
        urlrequest.httpMethod = "GET"
        
        let task = urlSession.dataTask(with: urlrequest) {[weak self] data, response, error in
            guard let self = self else { return }
            guard error == nil else {
                callback(Result.failure(error!))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                callback(Result.failure(EndpointError.corruptUrlResponse))
                return
            }
            
            guard let data = data else {
                callback(Result.failure(EndpointError.corruptData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                if let persistKey = persistKey {
                    self.userDefaults.set(data, forKey: persistKey)
                }
                callback(Result.success(result))
            } catch let e {
                callback(Result.failure(e))
            }
        }
        task.resume()
    }
}
