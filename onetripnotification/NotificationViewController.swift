//
//  NotificationViewController.swift
//  onetripnotification
//
//  Created by Emil Lundgren on 2018-11-02.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: NotificationViewModel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func didReceive(_ notification: UNNotification) {
        let userDefaults = UserDefaults(suiteName: "group.container.kebne.slonetripsearch")!
        let persistService = PersistService(userDefaults)
        guard let trips = persistService.retreive(SLJourneyPlanAPIResponse.self, valueForKey: "Trips") else { return }
        viewModel = NotificationViewModel(apiResponse: trips)
        tableView.register(UINib.init(nibName: "JourneyTableViewCellView", bundle: nil), forCellReuseIdentifier: JourneyTableViewCell.reuseIdentifier)
        tableView.register(UINib.init(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: TableViewHeaderView.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.reloadData()
        preferredContentSize = CGSize(width: view.frame.size.width, height: viewModel.preferedContentHeight + 40-0)
        titleLabel.text = notification.request.content.title

    }

}

extension NotificationViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.nrOfRowsIn(section: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.nrOfSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: JourneyTableViewCell = tableView.dequeueReusableCellAt(indexPath: indexPath)
        cell.viewModel = viewModel.cellModelFor(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: TableViewHeaderView = tableView.dequeueReusableHeaderFooterView()
        headerView.titleLabel.text = viewModel.titleFor(section: section)
        return headerView
    }
    
}

extension NotificationViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return JourneyTableViewCell.rowHeight
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewHeaderView.height
    }
}

class NotificationViewModel {
    
    var categories = [ProductCategory]()
    var journeyViewModels = [String:[JourneyTableViewCell.ViewModel]]()
    
    var totalNrOfRows: Int {
        return journeyViewModels.reduce(0, {$0 + $1.value.count})
    }
    
    var preferedContentHeight : CGFloat {
        var contentSize: CGFloat = 0.0
        for sectionIndex in categories.indices {
            contentSize = contentSize + (CGFloat(nrOfRowsIn(section: sectionIndex)) * JourneyTableViewCell.rowHeight)
        }
        return contentSize + (CGFloat(nrOfSections) * TableViewHeaderView.height)
    }
    
    init(apiResponse: SLJourneyPlanAPIResponse) {
        let sortedResults = Trip.sortInCategories(trips: apiResponse.trips)
        categories = sortedResults.sortedKeys
        for category in categories {
            var trips = sortedResults.dictionary[category]!
            trips.sort(by: {$0.arrivalDate < $1.arrivalDate})
            journeyViewModels[category.rawValue] = trips.map({JourneyTableViewCell.ViewModel(trip: $0)})
        }
    }
    
    var nrOfSections: Int {
        return categories.count
    }
    
    func cellModelFor(indexPath: IndexPath) ->JourneyTableViewCell.ViewModel {
        
        return journeyViewModels[categories[indexPath.section].rawValue]![indexPath.row]
    }
    
    func nrOfRowsIn(section: Int) ->Int {
        guard section < categories.count else {return 0}
        let nrOfRows = journeyViewModels[categories[section].rawValue]?.count ?? 0
        if nrOfRows > 3 && totalNrOfRows > 10 {
            return 3
        }
        return nrOfRows
    }
    
    func titleFor(section: Int) ->String? {
        
        if section < categories.count {
            return categories[section].description + " mot"
        }
        return nil
    }
    
}
