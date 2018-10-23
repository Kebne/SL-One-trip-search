//
//  JourneyViewModel.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-23.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

class JourneyViewModel {
    var start: String {
        return stateController.userJourneyController.userJourney?.start.name ?? ""
    }
    var destination: String {
        return stateController.userJourneyController.userJourney?.destination.name ?? ""
    }
    var time: String {
        if let minutes = stateController.userJourneyController.userJourney?.minutesUntilSearch {
            return "\(minutes)"
        } else {return ""}
    }
    
    var timeUnit: String {
        if let minutes = stateController.userJourneyController.userJourney?.minutesUntilSearch, minutes == 1 {
            return "minut."
        } else {return "minuter."}
    }
    
    var showActivityIndicator: Bool = false
    
    var newJourneyClosure: (()->Void)?
    
    private var categories = [ProductCategory]()
    private var journeyViewModels = [String:[JourneyTableViewCell.ViewModel]]()
    
    
    private let stateController: StateControllerProtocol
    
    init(stateController: StateControllerProtocol) {
        self.stateController = stateController
    }
    
    //MARK: Backing up the table view
    var nrOfSections: Int {
        return categories.count
    }
    
    func cellModelFor(indexPath: IndexPath) ->JourneyTableViewCell.ViewModel {
        
        return journeyViewModels[categories[indexPath.section].rawValue]![indexPath.row]
    }
    
    func nrOfRowsIn(section: Int) ->Int {
        return journeyViewModels[categories[section].rawValue]?.count ?? 0
    }
    
    func titleFor(section: Int) ->String? {
        if section < categories.count {
            return categories[section].description
        }
        return nil
    }
    
    //MARK: Action
    
    func didPressSwapButton() {
        stateController.userJourneyController.swapStations()
        fetchJourneyData()
    }
    
    //MARK: Fetch journey data
    
    func viewWillAppear() {
        categories.removeAll()
        journeyViewModels.removeAll()
        fetchJourneyData()
    }
    
    private func fetchJourneyData() {
        showActivityIndicator = true
        notifyCallback()
        stateController.fetchTrips() {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let response): self.handleAPI(response: response)
            case .failure(let error): print("Error fetching trips: \(error)")
            }
            self.showActivityIndicator = false
            self.notifyCallback()
        }
    }
    
    private func handleAPI(response: SLJourneyPlanAPIResponse) {
        let firstLegs = response.trips.sorted(by: {$0.duration < $1.duration}).reduce([Leg]()) {legs, nextTrip in
            if let nextLeg = nextTrip.legList.first(where: {$0.id == 0}), nextLeg.direction.count > 0 && nextLeg.product.line.count > 0 {
                return legs + [nextLeg]
            }
            return legs
        }
        categories = firstLegs.reduce([ProductCategory]()) {array, nextLeg ->[ProductCategory] in
            array.contains(nextLeg.product.category) ? array : array + [nextLeg.product.category]
        }
        for category in categories {
            journeyViewModels[category.rawValue] = response.trips.filter({$0.legList[0].product.category == category}).map({JourneyTableViewCell.ViewModel(trip: $0)})
        }
    }
    
    private func notifyCallback() {
        if Thread.current == Thread.main {
            newJourneyClosure?()
        } else {
            DispatchQueue.main.async {[weak self] in
                self?.newJourneyClosure?()
            }
        }
        
    }
}
