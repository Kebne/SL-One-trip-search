//
//  User.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

struct UserJourney {
    let start: Station
    let destination: Station
    let minutesUntilSearch: Int
    let monitorStationProximity: Bool
}
