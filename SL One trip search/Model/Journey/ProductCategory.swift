//
//  ProductCategory.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-22.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func colorFor(productCategory: ProductCategory, line: String) ->UIColor {
        
        switch productCategory {
        case .bus:
            let lineInt = Int(line) ?? 0
            return ProductCategory.blueBusLines.contains(lineInt) ? UIColor.slLineColorBusBlue : UIColor.slLineColorBusRed
        case .metro:
            let lineInt = Int(line) ?? 0
            if ProductCategory.blueMetroLines.contains(lineInt) { return UIColor.metroBlue}
            else if ProductCategory.redMetroLines.contains(lineInt) {return UIColor.metroRed}
            else if ProductCategory.greenMetroLines.contains(lineInt) {return UIColor.metroGreen}
        case .tram, .train: return UIColor.commuterTrainTram
        case .ferry, .ship: return UIColor.boatBlack
        case .unknown: return UIColor.boatBlack
        }
        
        return UIColor.boatBlack
    }
    
    static var slLineColorBusRed : UIColor {
        return UIColor(red: 164.0/255.0, green: 17.0/255.0, blue: 44.0/255.0, alpha: 1.0)
    }
    
    static var slLineColorBusBlue : UIColor {
        return UIColor(red: 0.0/255.0, green: 62.0/255.0, blue: 154.0/255.0, alpha: 1.0)
    }
    
    static var commuterTrainTram : UIColor {
        return UIColor(red: 164.0/255.0, green: 165.0/255.0, blue: 167.0/255.0, alpha: 1.0)
    }
    
    static var metroGreen : UIColor {
        return UIColor(red: 96.0/255.0, green: 164.0/255.0, blue: 43.0/255.0, alpha: 1.0)
    }
    
    static var metroRed : UIColor {
        return UIColor(red: 213.0/255.0, green: 20.0/255.0, blue: 39.0/255.0, alpha: 1.0)
    }
    
    static var metroBlue : UIColor {
        return UIColor(red: 28.0/255.0, green: 47.0/255.0, blue: 122.0/255.0, alpha: 1.0)
    }
    
    static var boatBlack : UIColor {
        return UIColor.black
    }
}

enum ProductCategory : String {
    case bus = "BUS"
    case metro = "METRO"
    case ferry = "FERRY"
    case ship = "SHIP"
    case train = "TRAIN"
    case tram = "TRAM"
    case unknown
    
    static let blueBusLines = [1,2,3,4,6,172,173,176,177,178,179,471,474,670,676,677,873,875]
    static let blueMetroLines = [10,11]
    static let redMetroLines = [13,14]
    static let greenMetroLines = [17,18,19]
}


extension ProductCategory : CustomStringConvertible {
    var description : String {
        switch self {
        case .bus: return NSLocalizedString("product.bus.categoryName", comment: "")
        case .metro: return NSLocalizedString("product.metro.categoryName", comment: "")
        case .ferry: return NSLocalizedString("product.ferry.categoryName", comment: "")
        case .ship: return NSLocalizedString("product.ship.categoryName", comment: "")
        case .train: return NSLocalizedString("product.train.categoryName", comment: "")
        case .tram: return NSLocalizedString("product.tram.categoryName", comment: "")
        case .unknown: return NSLocalizedString("product.unknown.categoryName", comment: "")
        }
    }
    
    var platformTypeString : String {
        switch self {
        case .bus: return NSLocalizedString("product.platformtype.bus", comment: "")
        case .metro: return NSLocalizedString("product.platformtype.metro", comment: "")
        case .ferry: return NSLocalizedString("product.platformtype.boat", comment: "")
        case .ship: return NSLocalizedString("product.platformtype.boat", comment: "")
        case .train: return NSLocalizedString("product.platformtype.train", comment: "")
        case .tram: return NSLocalizedString("product.platformtype.tram", comment: "")
        case .unknown: return ""
        }
    }
}

extension ProductCategory : Decodable {}

