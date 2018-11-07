//
//  JourneyViewModel.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-23.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

protocol JourneyViewModelDelegate : AnyObject {
    func didPressSettings()
    func didPressStartStationButton()
    func didPressEndStationButton()
    func showDetailView(for trip: Trip)
}

protocol JourneyPresentable {
    var start: String {get}
    var destination: String {get}
    var timeString: String {get}
    var showActivityIndicator: Bool {get}
    var newJourneyClosure: (()->Void)? {get set}
    var nrOfSections: Int {get}
    var latestSearchString: String {get}
    func cellModelFor(indexPath: IndexPath) ->JourneyTableViewCell.ViewModel
    func nrOfRowsIn(section: Int) ->Int
    func titleFor(section: Int) ->String?
    func refreshControlDidRefresh()
    func didPressSwapButton()
    func viewWillAppear()
    func didSelectTableViewCell(at indexPath: IndexPath)
    func didPressSettings()
    func didPressStartStationButton()
    func didPressEndStationButton()
}


class JourneyViewModel : JourneyPresentable {
    var start: String {
        return stateController.userJourneyController.userJourney?.start.name ?? Strings.noStation
    }
    var destination: String {
        return stateController.userJourneyController.userJourney?.destination.name ?? Strings.noStation
    }

    
    private var latestSearchDate: Date?
    weak var delegate: JourneyViewModelDelegate?
    
    var timeString: String {
        guard let minutes = stateController.userJourneyController.userJourney?.minutesUntilSearch else {
            return ""
        }
        
        if minutes == 0 {
            return Strings.timeLabel0Minutes
        } else if minutes == 1 {
            return Strings.timeLabel1Minute
        }
        
        return String(format: NSLocalizedString("journeyView.timeInfoLabel.moreThanOneMinute", comment: ""), "\(minutes)")
    }
    
    var latestSearchString: String {
        guard stateController.userJourneyController.userJourney != nil else {
            return ""
        }
        guard let latestSearchDate = latestSearchDate else {return Strings.searching}
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return Strings.latestSearch + ": " + timeFormatter.string(from: latestSearchDate)
    }
    
    var showActivityIndicator: Bool = false
    
    var newJourneyClosure: (()->Void)?
    
    private var categories = [ProductCategory]()
    //private var journeyViewModels = [String:[JourneyTableViewCell.ViewModel]]()
    private var tripSearchResult = [ProductCategory: [Trip]]()
    
    
    private let stateController: StateControllerProtocol
    
    init(stateController: StateControllerProtocol) {
        self.stateController = stateController
    }
    
    //MARK: Backing up the table view
    var nrOfSections: Int {
        return categories.count
    }
    
    func cellModelFor(indexPath: IndexPath) ->JourneyTableViewCell.ViewModel {
        let trip = tripSearchResult[categories[indexPath.section]]![indexPath.row]
        return JourneyTableViewCell.ViewModel(trip: trip)
    }
    
    func nrOfRowsIn(section: Int) ->Int {
        guard section < categories.count else {return 0}
        return tripSearchResult[categories[section]]?.count ?? 0
    }
    
    func titleFor(section: Int) ->String? {
        if section < categories.count {
            return categories[section].description + " " + Strings.towards
        }
        return nil
    }
    
    //MARK: Action
    
    func didSelectTableViewCell(at indexPath: IndexPath) {
        guard indexPath.section < categories.count,
            let tripArray = tripSearchResult[categories[indexPath.section]], indexPath.row < tripArray.count else { return }
        delegate?.showDetailView(for: tripArray[indexPath.row])
    }
    
    func didPressSettings() {
        delegate?.didPressSettings()
    }
    func didPressStartStationButton() {
        delegate?.didPressStartStationButton()
    }
    func didPressEndStationButton() {
        delegate?.didPressEndStationButton()
    }
    
    func refreshControlDidRefresh() {
        fetchJourneyData()
    }
    
    func didPressSwapButton() {
        stateController.userJourneyController.swapStations()
        fetchJourneyData()
    }
    
    func viewWillAppear() {
        fetchJourneyData()
    }
    
    //MARK: Fetch journey data

    private func fetchJourneyData() {
        categories.removeAll()
        tripSearchResult.removeAll()
        showActivityIndicator = true
        latestSearchDate = nil
        notifyCallback()
        stateController.fetchTrips(completion:{[weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let response): self.createTableViewDataFrom(response: response)
            case .failure(let error): print("Error fetching trips: \(error)")
            }
            self.showActivityIndicator = false
            self.latestSearchDate = Date()
            self.notifyCallback()
        }, usingLocation: false)
    }
    
    private func createTableViewDataFrom(response: SLJourneyPlanAPIResponse) {
        let sortedResult = Trip.sortInCategories(trips: response.trips)
        tripSearchResult = sortedResult.dictionary
        categories = sortedResult.sortedKeys
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

extension JourneyViewModel {
    enum Strings {
        static let timeLabel0Minutes = NSLocalizedString("journeyView.timeInfoLabel.zeroMinutes", comment: "")
        static let timeLabel1Minute = NSLocalizedString("journeyView.timeInfoLabel.oneMinute", comment: "")
        static let towards = NSLocalizedString("towards", comment: "")
        static let latestSearch = NSLocalizedString("journeyView.latestSearch", comment: "")
        static let searching = NSLocalizedString("journeyView.latestSearch.searching", comment: "")
        static let noStation = NSLocalizedString("journeyView.noStation", comment: "")
    }
}
