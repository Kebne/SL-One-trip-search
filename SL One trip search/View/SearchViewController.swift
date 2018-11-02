//
//  SearchViewController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate : AnyObject {
    func didSelectStation()
}

class SearchViewController: UIViewController {

    @IBOutlet weak var searchTableView: UITableView!
    var stationJourneyType: StationJourneyType!
    var stateController: StateControllerProtocol!
    let dataSource = SearchResultTableViewDataSource()
    let searchService = SearchService<StationSearchResult>()
    let searchController = UISearchController(searchResultsController: nil)
    weak var delegate: SearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.delegate = self
        searchTableView.dataSource = dataSource
        searchTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Sök station"
        
        //navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
        
    }

}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch stationJourneyType! {
        case .start:
            stateController.userJourneyController.start = dataSource.stations[indexPath.row]
        case .destination:
            stateController.userJourneyController.destination = dataSource.stations[indexPath.row]
        }
        
        delegate?.didSelectStation()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(StationTableViewCell.height)
    }
}

extension SearchViewController : UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
        if let journey = stateController.userJourneyController.userJourney {
            switch stationJourneyType! {
            case .start: searchController.searchBar.text = journey.start.name
            case .destination: searchController.searchBar.text = journey.destination.name
            }
            
        }
    }
    
    
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, searchText.count > 0, let searchRequest = StationSearchRequest(searchString: searchText) else {
            dataSource.stations = [Station]()
            searchTableView.reloadData()
            return}
        searchService.searchWith(request: searchRequest, callback: {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let stationSearchResult):
                self.dataSource.stations = stationSearchResult.values.map({$0.station})
            case .failure(_):
                self.dataSource.stations = [Station]()
            }
            DispatchQueue.main.async {
                self.searchTableView.reloadData()
            }
        })
    }
    
    

}

class SearchResultTableViewDataSource : NSObject, UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResultCell = tableView.dequeueReusableCell(withIdentifier: StationTableViewCell.reuseIdentifier, for: indexPath) as! StationTableViewCell
        if indexPath.row < viewModels.count {
           searchResultCell.viewModel = viewModels[indexPath.row]
        } else {
            searchResultCell.viewModel = StationTableViewCell.ViewModel()
        }
        
        
        return searchResultCell
    }
    
    var stations = [Station]() {
        didSet {
            viewModels = stations.map({StationTableViewCell.ViewModel(station: $0)})
        }
    }
    private var viewModels = [StationTableViewCell.ViewModel]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension SearchViewController : StoryboardInstantiable {}

