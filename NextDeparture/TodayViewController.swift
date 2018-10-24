//
//  TodayViewController.swift
//  NextDeparture
//
//  Created by Emil Lundgren on 2018-10-24.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var journeyTableView: UITableView!
    var stateController: StateControllerProtocol!
    var viewModel: JourneyViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults(suiteName: "group.container.kebne.slonetripsearch")!
        let persistService = PersistService(userDefaults)
        let userController = UserJourneyController(persistService: persistService)
        userController.attemptToRetreiveStoredJourney()
        stateController = StateController(userController: userController, journeyPlannerService: SearchService<SLJourneyPlanAPIResponse>())
        journeyTableView.dataSource = self
        viewModel = JourneyViewModel(stateController: stateController)
        journeyTableView.register(UINib.init(nibName: "JourneyTableViewCellView", bundle: nil), forCellReuseIdentifier: JourneyTableViewCell.reuseIdentifier)
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        viewModel.newJourneyClosure = {[weak self] in
            guard let self = self else {
                return
            }
            self.journeyTableView.reloadData()
            
        }
        // Do any additional setup after loading the view from its nib.
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        viewModel.viewWillAppear()
        
        completionHandler(NCUpdateResult.newData)
    }
    
}


extension TodayViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.nrOfRowsIn(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: JourneyTableViewCell.reuseIdentifier, for: indexPath) as! JourneyTableViewCell
        cell.viewModel = viewModel.cellModelFor(indexPath: indexPath)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.nrOfSections
    }
}
