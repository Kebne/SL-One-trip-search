//
//  JourneyDetailViewController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-05.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

class JourneyDetailViewController: UIViewController, StoryboardInstantiable {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: JourneyDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "JourneyDetailCellView", bundle: nil), forCellReuseIdentifier: JourneyDetailTableViewCell.reuseId)
        tableView.register(UINib.init(nibName: "JourneyDetailMapTableViewCell", bundle: nil), forCellReuseIdentifier: JourneyDetailMapTableViewCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.title = JourneyDetailViewModel.Strings.viewTitle
    }

}

extension JourneyDetailViewController : UITableViewDelegate {
    
}

extension JourneyDetailViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        return viewModel.nrOfRowsIn(section: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.nrOfSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell: JourneyDetailMapTableViewCell = tableView.dequeueReusableCellAt(indexPath: indexPath)
            cell.viewModel = viewModel.mapCellViewModel()
            return cell
        }
        
        let cell: JourneyDetailTableViewCell = tableView.dequeueReusableCellAt(indexPath: indexPath)
        cell.viewModel = viewModel.journeyCellViewModel(at: indexPath)
        return cell
        
    }
}

class JourneyDetailViewModel {
    
    enum Strings {
        static let viewTitle = NSLocalizedString("journeyDetail.title", comment: "")
    }
    
    var nrOfSections: Int = 2
    
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
    
    func mapCellViewModel() ->JourneyDetailMapTableViewCell.ViewModel {
        return JourneyDetailMapTableViewCell.ViewModel(trip: trip)
    }
    
 
}


