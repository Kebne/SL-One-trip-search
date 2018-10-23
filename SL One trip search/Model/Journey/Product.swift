//
//  Product.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-22.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

struct Product : Decodable {
    let category : ProductCategory
    let name: String
    let line: String
    
    enum CodingKeys: String, CodingKey {
        case category = "catOut"
        case name
        case line
    }
    
    
}


extension Product {
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        let catString = try root.decode(String.self, forKey: .category)
        if let cat = ProductCategory(rawValue: catString.replacingOccurrences(of: " ", with: "")) {
            category = cat
        } else {
            category = .unknown
        }
        line = try root.decode(String.self, forKey: .line)
        let nameString = try root.decode(String.self, forKey: .name)
        name = nameString.replacingOccurrences(of: line, with: "").replacingOccurrences(of: " ", with: "")
        
    }
}
