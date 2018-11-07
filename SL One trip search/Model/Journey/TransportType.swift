//
//  TransportType.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-07.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

extension String {
    func appendSpace() ->String {
        guard self.count > 0 else {
            return self
        }
        return self + " "
    }
}

enum TransportType {
    typealias WalkingDistance = Int
    case product(Product)
    case walk(WalkingDistance)
}

extension TransportType: CustomStringConvertible {
    var description: String {
        switch self {
        case .product(let product):
            return product.category.description
        case .walk(_):
            return NSLocalizedString("transporttype.walk", comment: "")
        }
    }
}

extension TransportType {
    var singleLetterDescription: String {
        switch self {
        case .product(let product):
            return product.category.singleLetterDescription
        case .walk(_):
            return NSLocalizedString("transporttype.walk.singleLetter", comment: "")
        }
    }
    
    var combineTypeLineDescription: String {
        switch self {
        case .product(let product):
            return description.appendSpace() + product.line
        case .walk(_):
            return description
        }
    }
    
    var platformTypeString: String {
        switch self {
        case .product(let product):
            return product.category.platformTypeString
        case .walk(_):
            return ""
        }
    }
}
