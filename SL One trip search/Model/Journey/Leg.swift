//
//  Leg.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-22.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation
import MapKit


struct Leg  {
    let origin: Origin
    let destination: Destination
    let id: Int
    let transportType: TransportType
    let hidden: Bool
    let direction: String
    let stops: [Stop]
    let coordinates: [CLLocationCoordinate2D]
}

extension Leg : Decodable {
    enum CodingKeys : String, CodingKey {
        case origin = "Origin"
        case destination = "Destination"
        case id = "idx"
        case product = "Product"
        case direction
        case type
        case dist
        case hide
        case stops = "Stops"
        case coordinates = "Polyline"
    }
    
    enum StopKeys : String, CodingKey {
        case stop = "Stop"
    }
    
    enum PolylineKeys : String, CodingKey {
        case crd
    }

    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        origin = try root.decode(Origin.self, forKey: .origin)
        destination = try root.decode(Destination.self, forKey: .destination)
        let idString = try root.decode(String.self, forKey: .id)
        id = Int(idString) ?? -1
        let type = try root.decode(String.self, forKey: .type)
        let walkingDistance = (try? root.decode(Int.self, forKey: .dist)) ?? 0
        hidden = (try? root.decode(Bool.self, forKey: .hide)) ?? false
        if let product = try? root.decode(Product.self, forKey: .product) {
            transportType = TransportType.product(product)
        } else if type == "WALK" {
            transportType = TransportType.walk(walkingDistance)
        } else {
            transportType = TransportType.product(Product(category: .unknown, name: "", line: ""))
        }
        if let direction = try? root.decode(String.self, forKey: .direction) {
            self.direction = direction
        } else {
            direction = ""
        }
        
        var allStops = [Stop]()
        var coords = [CLLocationCoordinate2D]()
        if let stopContainer = try? root.nestedContainer(keyedBy: StopKeys.self, forKey: .stops) {
            allStops = try stopContainer.decode([Stop].self, forKey: .stop)
        }
        
        if let polylineContainer = try? root.nestedContainer(keyedBy: PolylineKeys.self, forKey: .coordinates) {
            let intValues = try polylineContainer.decode([Int].self, forKey: .crd)
            coords = CLLocationCoordinate2D.coordinatesFrom(slResponse: intValues)
        } else {
            coords = [CLLocationCoordinate2D(latitude: origin.latitude, longitude: origin.longitude),
            CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)]
        }
        coordinates = coords
        stops = allStops
    }
}

extension CLLocationCoordinate2D {
    static func coordinatesFrom(slResponse: [Int]) ->[CLLocationCoordinate2D] {
        var array = [CLLocationCoordinate2D]()
        guard slResponse.count % 2 == 0, slResponse.count > 2 else {
            return array
        }

        var startLong = slResponse[0]
        var startLat = slResponse[1]
        array.append(CLLocationCoordinate2D(latitude: startLat.coordinateDegreesValue, longitude: startLong.coordinateDegreesValue))
        
        for index in stride(from: 2, to: slResponse.count, by: 2) {
            
            startLong = startLong + slResponse[index]
            startLat = startLat + slResponse[index + 1]
            array.append(CLLocationCoordinate2D(latitude: startLat.coordinateDegreesValue, longitude: startLong.coordinateDegreesValue))
        }
        
        return array
    }
}

extension Int {
    var coordinateDegreesValue: Double {
        let nrOfDigits = Int(log10(Double(self)) + 1.0)
        return Double(self) / pow(10.0, Double(nrOfDigits - 2))
    }
}


extension Leg: CustomStringConvertible {
    var description: String {
        return direction.appendSpace() + transportType.platformTypeString.appendSpace() + origin.track + " - " + origin.time.presentableTimeString
    }
}

extension Leg {
    
    var polyline: MKPolyline {
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    var startStopAnnotations: [StopAnnotation] {
        let start = StopAnnotation(UIColor.color(for: transportType), letter: transportType.singleLetterDescription, coordinate: origin.coordinate)
        let end = StopAnnotation(UIColor.color(for: transportType), letter: transportType.singleLetterDescription, coordinate: destination.coordinate)
        return [start,end]
    }
    
    var stopAnnotations: [StopAnnotation] {
        return stops.filter({$0.latitude != origin.latitude && $0.longitude != origin.longitude}).filter(({$0.latitude != destination.latitude && $0.longitude != destination.longitude})).map({StopAnnotation(UIColor.color(for: transportType), letter: "", coordinate: $0.coordinate)})
    }
    
    
    
    var stopCircles: [MKCircle] {
        return stops.map({MKCircle(center:$0.coordinate, radius: 50.0)})
    }
    
    
    func renderer(for overlay: MKOverlay) ->MKOverlayRenderer {
        if overlay is MKPolyline { return lineRenderer(for:overlay)}
        else if let circle = overlay as? MKCircle {return circleRenderer(for: circle)}
        return MKOverlayRenderer()
    }
    
    private func lineRenderer(for overlay: MKOverlay) ->MKOverlayRenderer {
        let lineRenderer = MKPolylineRenderer(overlay: overlay)
        lineRenderer.lineWidth = 2.0
        lineRenderer.strokeColor = UIColor.color(for: transportType)
        return lineRenderer
    }
    
    private func circleRenderer(for circleOverlay: MKCircle) ->MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.fillColor = UIColor.color(for: transportType)
        return circleRenderer
    }
}

