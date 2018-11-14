//
//  MapViewController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-09.
//  Copyright © 2018 Kebne. All rights reserved.
//

import MapKit

class MapViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var map: MKMapView!
    var mapViewModel: MapViewModelType!
    private var mapViewDelegate: MapDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMap()
    }
    
    
    private func prepareMap() {
        mapViewDelegate = MapDelegate(mapViewModel)
        map.delegate = mapViewDelegate
        map.setRegion(mapViewModel.region, animated: false)
        map.addOverlays(mapViewModel.overlays)
        map.addAnnotations(mapViewModel.circleAnnotations)
        map.addAnnotations(mapViewModel.annotations)
    }

}
