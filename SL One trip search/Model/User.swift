//
//  User.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

struct User {
    var start: Station?
    var destination: Station?
    var timeFromNowToSearchForJourney: TimeInterval
    var monitorPosition: Bool = false
}
