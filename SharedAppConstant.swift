//
//  SharedAppConstant.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-29.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

enum SharedAppConstant {
    static let urlPathFrom = "from"
    static let urlPathDestination = "destination"
}

extension URL {
    static let oneTripScheme = "onesearchwidget"
    static var fromStation: URL {
         var urlComponents = defaultURLComponents
        urlComponents.host = SharedAppConstant.urlPathFrom
        return urlComponents.url!
    }
    
    static var destStation: URL {
        var urlComponents = defaultURLComponents
        urlComponents.host = SharedAppConstant.urlPathDestination
        return urlComponents.url!
    }
    
    private static var defaultURLComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = URL.oneTripScheme
        return urlComponents
    }
}
