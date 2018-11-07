//
//  JourneyDetailTableViewCell.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-06.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit



class JourneyDetailTableViewCell: UITableViewCell, ReusableTableViewCell {

    
    @IBOutlet weak var topLeftLabel: UILabel!
    @IBOutlet weak var topRightLabel: UILabel!
    @IBOutlet weak var bottomLeftLabel: UILabel!
    @IBOutlet weak var bottomRightLabel: UILabel!
    @IBOutlet weak var topDetailLabel: UILabel!
    @IBOutlet weak var bottomDetailLabel: UILabel!
    @IBOutlet weak var topDotView: UIView!
    @IBOutlet weak var bottomDotView: UIView!
    @IBOutlet weak var connectingLineView: UIView!
    @IBOutlet weak var singleLetterLabel: UILabel!
    @IBOutlet weak var roundedContentView: UIView!
    
    var viewModel = ViewModel() {
        didSet {
            topLeftLabel.text = viewModel.topLeftLabelText
            topRightLabel.text = viewModel.topRightLabelText
            topDetailLabel.text = viewModel.topDetailLabelText
            bottomDetailLabel.text = viewModel.bottomDetailLabelText
            bottomLeftLabel.text = viewModel.bottomLeftLabelText
            bottomRightLabel.text = viewModel.bottomRightLabelText
            singleLetterLabel.text = viewModel.singleLetter
            topDotView.backgroundColor = viewModel.dotsLineColor
            bottomDotView.backgroundColor = viewModel.dotsLineColor
            connectingLineView.backgroundColor = viewModel.dotsLineColor
            singleLetterLabel.backgroundColor = viewModel.dotsLineColor
            roundedContentView.layer.shadowColor = UIColor.black.cgColor
            topDetailLabel.isHidden = viewModel.topDetailIsHidden
        }
    }

}

extension JourneyDetailTableViewCell {
    struct ViewModel {
        let topLeftLabelText: String
        let topRightLabelText: String
        let bottomLeftLabelText: String
        let bottomRightLabelText: String
        let topDetailLabelText: String
        let bottomDetailLabelText: String
        let dotsLineColor: UIColor
        let singleLetter: String
        let topDetailIsHidden: Bool
        
        init() {
            topLeftLabelText = ""
            topRightLabelText = ""
            bottomLeftLabelText = ""
            bottomRightLabelText = ""
            topDetailLabelText = ""
            bottomDetailLabelText = ""
            dotsLineColor = UIColor.black
            singleLetter = ""
            topDetailIsHidden = true
        }
        
        init(leg: Leg) {
            topLeftLabelText = leg.origin.time.hourMinuteTimeString
            topRightLabelText = leg.origin.name.separateParenthesisString().string
            bottomLeftLabelText = leg.destination.time.hourMinuteTimeString
            bottomRightLabelText = leg.destination.name.separateParenthesisString().string
            switch leg.transportType {
            case .product(let product):
                bottomDetailLabelText = product.category.description + " " + product.line + " " + JourneyViewModel.Strings.towards + " " + leg.direction
                topDetailLabelText = leg.origin.track.count > 0 ?  leg.origin.name.separateParenthesisString().inParentheses.appendSpace() + product.category.platformTypeString + " " + leg.origin.track : ""
            case .walk(let distance):
                bottomDetailLabelText = leg.transportType.description + " " + "\(distance)" + " m"
                topDetailLabelText = ""
            }
            dotsLineColor = UIColor.color(for: leg.transportType)
            singleLetter = leg.transportType.singleLetterDescription
            topDetailIsHidden = topDetailLabelText.count == 0

        }
    }
}
