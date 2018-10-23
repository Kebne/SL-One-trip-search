//
//  SLJourneyPlanAPIResponse.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-22.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation


struct SLJourneyPlanAPIResponse : Decodable {
    let trips: [Trip]
    enum CodingKeys : String, CodingKey {
        case trips = "Trip"
    }
}
