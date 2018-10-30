//
//  ViewController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

protocol JourneyViewControllerDelegate : AnyObject {
    func didPressSettings()
    func didPressStartStationButton()
    func didPressEndStationButton()
}

protocol NotificationCenterProtocol {
    func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?)
    func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?)
}

extension NotificationCenter : NotificationCenterProtocol {}


class JourneyViewController: UIViewController, StoryboardInstantiable {
    
    weak var delegate: JourneyViewControllerDelegate?
    
    @IBOutlet weak var startStationButton: UIButton!
    @IBOutlet weak var destinationStationButton: UIButton!
    
    @IBOutlet weak var latestSearchLabel: UILabel!
    
    @IBOutlet weak var timeInfoLabel: UILabel!
    @IBOutlet weak var journeyTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
   

    var notificationCenter: NotificationCenterProtocol! = NotificationCenter.default
    var stateController: StateControllerProtocol!
    var viewModel: JourneyPresentable!
    
    @IBAction func didPressSettingsButton(_ sender: UIBarButtonItem) {
        delegate?.didPressSettings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        journeyTableView.dataSource = self
        journeyTableView.delegate = self
        journeyTableView.tableFooterView = UIView(frame: CGRect.zero)
        journeyTableView.refreshControl = refreshControl
        journeyTableView.register(UINib.init(nibName: "JourneyTableViewCellView", bundle: nil), forCellReuseIdentifier: JourneyTableViewCell.reuseIdentifier)
        journeyTableView.register(UINib.init(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: TableViewHeaderView.reuseId)
        refreshControl.addTarget(self, action: #selector(refreshControllerDidRefresh), for: .valueChanged)
        viewModel.newJourneyClosure = {[weak self] in
            guard let self = self else {return}
            self.render()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerAppBecomeActiveObserver(on: true)
        viewModel.viewWillAppear()
        render()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        registerAppBecomeActiveObserver(on: false)
    }
    
    func render() {
        startStationButton.setTitle(viewModel.start, for: .normal)
        destinationStationButton.setTitle(viewModel.destination, for: .normal)
        timeInfoLabel.text = viewModel.timeString
        latestSearchLabel.text = viewModel.latestSearchString
        if !refreshControl.isRefreshing {
            activityIndicator.isHidden = !viewModel.showActivityIndicator
            viewModel.showActivityIndicator ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
        if !viewModel.showActivityIndicator {
            refreshControl.endRefreshing()
        }
  
        journeyTableView.reloadData()
    }
    
    private func registerAppBecomeActiveObserver(on: Bool) {
        
        if on {
            notificationCenter.addObserver(
                self,
                selector: #selector(didReceiceAppBecomeActiveNotification),
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
        } else {
            notificationCenter.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }
    
    
    
    //MARK: Action
    
    @objc private func didReceiceAppBecomeActiveNotification() {
        viewModel.viewWillAppear()
    }
    
    @objc private func refreshControllerDidRefresh() {
        viewModel.refreshControlDidRefresh()
    }
    
    @IBAction func didTapStartStationButton() {
        delegate?.didPressStartStationButton()
    }
    
    @IBAction func didTapEndStationButton(_ sender: Any) {
        delegate?.didPressEndStationButton()
    }
    
    @IBAction func didPressSwapStationsButton() {
        viewModel.didPressSwapButton()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        startStationButton.contentHorizontalAlignment = .left
        destinationStationButton.contentHorizontalAlignment = .left
    }
}

extension JourneyViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return JourneyTableViewCell.rowHeight
    }
}

extension JourneyViewController : UITableViewDataSource {
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



