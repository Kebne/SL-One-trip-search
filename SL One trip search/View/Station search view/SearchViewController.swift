//
//  SearchViewController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit



class SearchViewController: UIViewController {

    @IBOutlet weak var searchTableView: UITableView!


    let searchController = UISearchController(searchResultsController: nil)
    var viewModel: StationSearchViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Sök station"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
        viewModel.renderCallback = {[weak self] in
            guard let self = self else {return}
            self.searchTableView.reloadData()
        }
        
    }

}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.tableViewDidSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(StationTableViewCell.height)
    }
}

extension SearchViewController : UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
        searchController.searchBar.text = viewModel.searchBarText
    }
    
    
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {return}
        viewModel.searchBarTextUpdated(to: text)
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResultCell: StationTableViewCell = tableView.dequeueReusableCellAt(indexPath: indexPath)
        searchResultCell.viewModel = viewModel.cellViewModel(for: indexPath)
        return searchResultCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.nrOfRowsIn(section: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.nrOfSectionsInTableView()
    }
}

extension SearchViewController : StoryboardInstantiable {}

