//
//  JourneyTableViewCell.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-22.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

extension Date {
    var presentableTimeString : String {
        
        if abs(self.timeIntervalSinceNow) > 20 * 60 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: self)
        } else if abs(self.timeIntervalSinceNow) <= 60 {
            return NSLocalizedString("nu", comment: "")
        }
        
        return "\(Int(abs(self.timeIntervalSinceNow) / 60.0)) " + NSLocalizedString("min", comment: "")
        
    }
    
    var hourMinuteTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
}

extension UIColor {
    static var trackLabelGray : UIColor {
        return UIColor(red: 154.0/255.0, green: 154.0/255.0, blue: 154.0/255.0, alpha: 1.0)
    }
}

protocol ReusableTableViewCell : AnyObject {
    static var reuseId: String {get}
}

extension ReusableTableViewCell {
    static var reuseId: String {
        return String(describing: Self.self)
    }
}

extension UITableView {
    func dequeueReusableCellAt<T: ReusableTableViewCell>(indexPath: IndexPath) ->T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseId, for: indexPath) as? T else {
            fatalError("Unable to dequeue or cast UITableViewCell to correct type: \(T.self). Make sure that the storyboard reuse identifier is the name of the class.")
        }
        return cell
    }
}


class JourneyTableViewCell: UITableViewCell, ReusableTableViewCell {
    @IBOutlet weak var lineNumberText: UITextView!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var journeyStatsLabel: UILabel!
    
    static let reuseIdentifier = "JourneyTableViewCell"
    static let nibName = "JourneyTableViewCellView"
    static let rowHeight: CGFloat = 60.0
    

    
    var viewModel: ViewModel = ViewModel() {
        didSet {
            lineNumberText.text = viewModel.lineNumber
            destinationLabel.text = viewModel.destination
            trackLabel.text = viewModel.track
            timeLabel.text = viewModel.time
            trackLabel.isHidden = !viewModel.showTrack
            trackLabel.backgroundColor = viewModel.trackColor
            lineNumberText.backgroundColor = viewModel.categoryColor
            journeyStatsLabel.text = viewModel.journeyStats
           
        }
    }

}


extension JourneyTableViewCell {
    struct ViewModel {
        let lineNumber: String
        let destination: String
        let track: String
        let time: String
        let category: String
        let showTrack: Bool
        let categoryColor: UIColor
        let trackColor: UIColor
        var journeyStats: String
        
        init() {
            lineNumber = ""
            destination = ""
            track = ""
            time = ""
            category = ""
            showTrack = false
            trackColor = UIColor.clear
            categoryColor = UIColor.slLineColorBusRed
            journeyStats = ""
        }
        
        init(leg: Leg) {
            lineNumber = leg.product.line
            track = leg.origin.track
            time = leg.origin.time.presentableTimeString
            category = leg.product.category.rawValue
            destination = leg.direction
            showTrack = track.count > 0 ? true : false
            trackColor = track.count > 0 ? UIColor.trackLabelGray : UIColor.clear
            categoryColor = UIColor.colorFor(productCategory: leg.product.category, line: leg.product.line)
            journeyStats = ""
        }
        
        init(trip: Trip) {
            guard let firstLeg = trip.legList.first(where: {$0.id == 0}) else {
                self.init()
                return
            }
            self.init(leg: firstLeg)
            let nrOfTripChanges = trip.legList.filter({$0.product.category != .unknown}).count - 1
            self.journeyStats = statsStringFrom(nrOfTripChanges: nrOfTripChanges, duration: trip.duration, arrivalDate: trip.arrivalDate)
        }
        
        private func statsStringFrom(nrOfTripChanges: Int, duration: TimeInterval, arrivalDate: Date) ->String {
            var tripChangesString = ""
            switch nrOfTripChanges {
            case 0: tripChangesString = Strings.noChanges
            case 1: tripChangesString = Strings.oneChange
            default: tripChangesString = String(format: Strings.multipleChanges, "\(nrOfTripChanges)")
            }
            let durationString = String(format: Strings.durationString, arrivalDate.hourMinuteTimeString, "\(Int(duration / 60.0))")
            return durationString + ", " + tripChangesString
        }
    }
}

extension JourneyTableViewCell.ViewModel {
    enum Strings {
        static let noChanges = NSLocalizedString("journeyView.journeyStats.noChanges", comment: "")
        static let oneChange = NSLocalizedString("journeyView.journeyStats.oneChange", comment: "")
        static let multipleChanges = NSLocalizedString("journeyView.journeyStats.multipleChanges", comment: "")
        static let durationString = NSLocalizedString("journeyView.journeyStats.travelTime", comment: "")
    }
}
