//
//  DateExtension.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-13.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
extension Date {
    func dateByAdding(_ minutes: Int) ->Date {
        return self.addingTimeInterval(Double(minutes * 60))
    }
    
    var slRequestTimeString: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: self)
    }
    
    var slRequestDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    static func dateFromSLJourneyPlan(timeString: String, dateString: String) ->Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: dateString + " " + timeString) {
            return date
        }
        return Date()
    }
}
