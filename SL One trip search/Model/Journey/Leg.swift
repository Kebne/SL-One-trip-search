//
//  Leg.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-22.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

struct Leg  {
    let origin: Origin
    let destination: Destination
    let id: Int
    let product: Product
    let direction: String
    
}

extension Leg : Codable{
    enum CodingKeys : String, CodingKey {
        case origin = "Origin"
        case destination = "Destination"
        case id = "idx"
        case product = "Product"
        case direction
    }
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        origin = try root.decode(Origin.self, forKey: .origin)
        destination = try root.decode(Destination.self, forKey: .destination)
        let idString = try root.decode(String.self, forKey: .id)
        id = Int(idString) ?? -1
        if let product = try? root.decode(Product.self, forKey: .product) {
            self.product = product
        } else {
            product = Product(category: .unknown, name: "", line: "")
        }
        if let direction = try? root.decode(String.self, forKey: .direction) {
            self.direction = direction
        } else {
            direction = ""
        }
        
    }
}
