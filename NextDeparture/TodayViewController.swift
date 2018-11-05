//
//  TodayViewController.swift
//  NextDeparture
//
//  Created by Emil Lundgren on 2018-10-24.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation
class TodayViewController: UIViewController, NCWidgetProviding {
    
    fileprivate struct Constant {
        static let nrOfInfoLabels = 4
    }
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var searchFromTimeInfoLabel: UILabel!
    @IBOutlet weak var destinationStationButton: UIButton!
    @IBOutlet weak var startStationButton: UIButton!
    @IBOutlet weak var labelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var journeyTableView: UITableView!
    var stateController: StateControllerProtocol!
    var viewModel: JourneyViewModel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    
        let userDefaults = UserDefaults(suiteName: "group.container.kebne.slonetripsearch")!
        let persistService = PersistService(userDefaults)
        let locationService = LocationService(locationManager: CLLocationManager())
        let userController = UserJourneyController(persistService: persistService, locationService: locationService)
        userController.attemptToRetreiveStoredJourney()
        
        stateController = StateController(userController: userController, journeyPlannerService: SearchService<SLJourneyPlanAPIResponse>(), locationService: locationService,
                                          notificationService: NotificationService())
        viewModel = JourneyViewModel(stateController: stateController)
        
        journeyTableView.tableFooterView = UIView(frame: CGRect.zero)
        journeyTableView.register(UINib.init(nibName: JourneyTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: JourneyTableViewCell.reuseIdentifier)
        journeyTableView.register(UINib.init(nibName: TableViewHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: TableViewHeaderView.reuseId)
        journeyTableView.dataSource = self
        journeyTableView.delegate = self
        
        searchButton.contentHorizontalAlignment = .left
        destinationStationButton.contentHorizontalAlignment = .left
        startStationButton.contentHorizontalAlignment = .left
        render()
        
        viewModel.newJourneyClosure = {[weak self] in
            guard let self = self else {
                return
            }
            self.render()
        }
    }
    
    private func render() {
        startStationButton.setTitle(viewModel.start, for: .normal)
        destinationStationButton.setTitle(viewModel.destination, for: .normal)
        searchButton.setTitle(viewModel.latestSearchString, for: .normal)
        searchFromTimeInfoLabel.text = viewModel.timeString
        updateContentSize()
        journeyTableView.reloadData()
    }

    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        viewModel.viewWillAppear()
        completionHandler(NCUpdateResult.newData)
    }
    
    private func calculateHeight() ->CGFloat {
        
        guard let viewModel = viewModel else {return 0.0}
        var height: CGFloat = 0.0
        for sectionNr in 0..<viewModel.nrOfSections {
            height = height + (CGFloat(viewModel.nrOfRowsIn(section: sectionNr)) * JourneyTableViewCell.rowHeight)
        }
        
        height = height + CGFloat(viewModel.nrOfSections) * TableViewHeaderView.height
        
        return height + (labelHeightConstraint.constant * CGFloat(Constant.nrOfInfoLabels)) + topSpacingConstraint.constant +
            tableViewTopConstraint.constant
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0.0, height: calculateHeight())
        } else {
            preferredContentSize = maxSize
        }
    }
    
    private func updateContentSize() {
        guard let extensionContext = extensionContext else {return}
        if extensionContext.widgetActiveDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0.0, height: calculateHeight())
        }
    }
    
    
    
    //MARK: Action
    @IBAction func didPressSwapButton(_ sender: UIButton) {
        viewModel.didPressSwapButton()
    }
    
    
    @IBAction func didPressSearchButton() {
        viewModel.refreshControlDidRefresh()
    }
    
    @IBAction func didPressFromStationButton() {
        extensionContext?.open(URL.fromStation, completionHandler: nil)
    }
    
    @IBAction func didPressDestinationStationButton() {
        extensionContext?.open(URL.destStation, completionHandler: nil)
    }
}


extension TodayViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return JourneyTableViewCell.rowHeight
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewHeaderView.height
    }
}

extension TodayViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.nrOfRowsIn(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: JourneyTableViewCell = tableView.dequeueReusableCellAt(indexPath: indexPath)
        cell.viewModel = viewModel.cellModelFor(indexPath: indexPath)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.nrOfSections
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: TableViewHeaderView = tableView.dequeueReusableHeaderFooterView()
        headerView.titleLabel.text = viewModel.titleFor(section: section)
        return headerView
    }
}
