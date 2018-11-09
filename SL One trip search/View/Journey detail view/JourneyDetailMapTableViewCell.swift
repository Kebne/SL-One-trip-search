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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var viewModel = ViewModel() {
        didSet {
            mapView.delegate = self
            mapView.setRegion(viewModel.region, animated: false)
            mapView.addOverlays(viewModel.overlays)
            
        }
    }

    
}

extension JourneyDetailMapTableViewCell : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let lineRenderer = MKPolylineRenderer(overlay: overlay)
        lineRenderer.lineWidth = 2.0
        lineRenderer.strokeColor = UIColor.red
        return lineRenderer
    }
}

extension JourneyDetailMapTableViewCell {
    struct ViewModel {
        let region: MKCoordinateRegion
        let overlays: [MKOverlay]
    
        
        init(trip: Trip) {
            overlays = trip.legList.map({$0.polyline})
            region = trip.mkRegion
        }
        
        init() {
            overlays = [MKOverlay]()
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 59.332790, longitude: 18.064490), latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
        }
    }
}
