//
//  JourneyDetailMapTableViewCell.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-08.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit
import MapKit

class JourneyDetailMapTableViewCell: UITableViewCell, ReusableTableViewCell {
    
    @IBOutlet weak var mapView: MKMapView!
    private var mapKitDelegate: MapDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var viewModel = MapViewModel() {
        didSet {
            mapKitDelegate = MapDelegate(viewModel)
            mapView.delegate = mapKitDelegate
            mapView.setRegion(viewModel.region, animated: false)
            mapView.addOverlays(viewModel.overlays)
            mapView.addAnnotations(viewModel.annotations)
        }
    }
}







