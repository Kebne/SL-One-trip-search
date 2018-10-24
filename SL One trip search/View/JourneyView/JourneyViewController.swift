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

class JourneyViewController: UIViewController, StoryboardInstantiable {
    
    weak var delegate: JourneyViewControllerDelegate?
    
    @IBOutlet weak var startStationButton: UIButton!
    @IBOutlet weak var destinationStationButton: UIButton!
    
    
    @IBOutlet weak var timeInfoLabel: UILabel!
    @IBOutlet weak var journeyTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()


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
        refreshControl.addTarget(self, action: #selector(refreshControllerDidRefresh), for: .valueChanged)
        viewModel.newJourneyClosure = {[weak self] in
            guard let self = self else {return}
            self.render()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
        render()
    }
    
    func render() {
        startStationButton.setTitle(viewModel.start, for: .normal)
        destinationStationButton.setTitle(viewModel.destination, for: .normal)
        timeInfoLabel.text = viewModel.timeString
        if !refreshControl.isRefreshing {
            activityIndicator.isHidden = !viewModel.showActivityIndicator
            viewModel.showActivityIndicator ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
        if !viewModel.showActivityIndicator {
            refreshControl.endRefreshing()
        }
  
        journeyTableView.reloadData()
    }
    
    //MARK: Action
    
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleFor(section: section)
    }
}

extension JourneyViewController : UITableViewDataSource {
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



