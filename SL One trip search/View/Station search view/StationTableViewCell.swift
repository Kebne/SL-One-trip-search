//
//  StationTableViewCell.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-18.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

class StationTableViewCell: UITableViewCell, ReusableTableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var additionalNameLabel: UILabel!
    static let height = 65

    
    var viewModel: ViewModel = ViewModel() {
        didSet {
            nameLabel.text = viewModel.name
            additionalNameLabel.text = viewModel.additionalName
        }
    }

}

extension StationTableViewCell {
    struct ViewModel {
        let name: String
        let additionalName: String
        
        init() {
            name = ""
            additionalName = ""
        }
        
        init(station: Station) {
            name = station.name
            additionalName = station.area
        }
    }
}
