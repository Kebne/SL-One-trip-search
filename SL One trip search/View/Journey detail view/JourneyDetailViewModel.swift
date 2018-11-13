//
//  JourneyDetailViewModel.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-09.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

protocol JourneyDetailViewModelDelegate : AnyObject {
    func showMapView(for trip: Trip)
}

class JourneyDetailViewModel {
    
    enum Strings {
        static let viewTitle = NSLocalizedString("journeyDetail.title", comment: "")
    }
    
    var nrOfSections: Int = 2
    weak var delegate: JourneyDetailViewModelDelegate?
    
    private let trip: Trip
  
    
    init(_ trip: Trip) {
        self.trip = trip
    }
    
    //MARK: table view
    func nrOfRowsIn(section: Int) ->Int {
        return trip.legList.filter({!$0.hidden}).count
    }
    

    
    func journeyCellViewModel(at indexPath: IndexPath) ->JourneyDetailTableViewCell.ViewModel {
        return JourneyDetailTableViewCell.ViewModel(leg: trip.legList.filter({!$0.hidden})[indexPath.row])
    }
    
    func mapCellViewModel() ->MapViewModel {
        return MapViewModel(trip: trip)
    }
    
    func didSelectCell(at indexPath: IndexPath) {
        if indexPath.section == 1 {
            delegate?.showMapView(for: trip)
        }
    }
    
}
