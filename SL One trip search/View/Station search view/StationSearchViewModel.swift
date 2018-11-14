//
//  StationSearchViewModel.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-13.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation


protocol StationSearchViewModelType {
    
    var searchBarText: String {get}
    func nrOfSectionsInTableView() ->Int
    func nrOfRowsIn(section: Int) ->Int
    func cellViewModel(for indexPath: IndexPath) ->StationTableViewCell.ViewModel
    func searchBarTextUpdated(to searchString: String)
    func tableViewDidSelectRow(at indexPath: IndexPath)
    
    var renderCallback: (()->Void)? {get set}
    
}

protocol SearchViewModelDelegate : AnyObject {
    func didSelectStation()
}


class StationSearchViewModel : StationSearchViewModelType {
    
    private var stateController: StateControllerProtocol
    private let searchService: SearchService<StationSearchResult>
    private let stationJourneyType: StationJourneyType
    private var stations = [Station]()
    var renderCallback: (() -> Void)?
    weak var delegate: SearchViewModelDelegate?
    
    init(stateController: StateControllerProtocol, searchService: SearchService<StationSearchResult>, stationJourneyType: StationJourneyType) {
        self.stateController = stateController
        self.searchService = searchService
        self.stationJourneyType = stationJourneyType
    }
    
    var searchBarText: String {
        switch stationJourneyType {
        case .destination:
            return stateController.userJourneyController.userJourney?.destination.name ?? stateController.userJourneyController.destination?.name ?? ""
        case .start:
            return stateController.userJourneyController.userJourney?.start.name ?? stateController.userJourneyController.start?.name ?? ""
        }
    }
    
    func nrOfSectionsInTableView() -> Int {
        return 1
    }
    
    func nrOfRowsIn(section: Int) -> Int {
        return stations.count
    }
    
    func cellViewModel(for indexPath: IndexPath) -> StationTableViewCell.ViewModel {
        if indexPath.row < stations.count {
            return StationTableViewCell.ViewModel(station: stations[indexPath.row])
        }
        return StationTableViewCell.ViewModel()
    }
    
    func searchBarTextUpdated(to searchString: String) {
        guard searchString.count > 0, let searchRequest = StationSearchRequest(searchString: searchString) else {
            stations.removeAll()
            notifyRenderCallback()
            return
            
        }
        searchService.searchWith(request: searchRequest, callback: {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let stationSearchResult):
                self.stations = stationSearchResult.values.map({$0.station})
            case .failure(_):
                self.stations.removeAll()
            }
            self.notifyRenderCallback()
        })
    }
    
    private func notifyRenderCallback() {
        guard let callback = renderCallback else {return}
        if Thread.current == .main {
            callback()
        } else {
            DispatchQueue.main.async {
                callback()
            }
        }
    }
    
    //MARK: Action
    func tableViewDidSelectRow(at indexPath: IndexPath) {
        switch stationJourneyType {
        case .start:
            stateController.userJourneyController.start = stations[indexPath.row]
        case .destination:
            stateController.userJourneyController.destination = stations[indexPath.row]
        }
        delegate?.didSelectStation()
    }
    
    
}
