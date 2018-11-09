//
//  StartStopAnnotationView.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-09.
//  Copyright © 2018 Kebne. All rights reserved.
//


import MapKit

class StartStopAnnotationView : MKAnnotationView {
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    @IBOutlet var contentView: StartStopAnnotationView!
    
    init(_ annotation: StopAnnotation) {
        super.init(annotation: annotation, reuseIdentifier: nil)
        Bundle.main.loadNibNamed("StartStopAnnotationView", owner: self, options: nil)
        contentView.frame = self.bounds
        addSubview(contentView)
        draw(bgColor: annotation.color, letter: annotation.letter)
    }
    
    private func draw(bgColor: UIColor, letter: String) {
        
        circleView.backgroundColor = bgColor
        textLabel.text = letter
        if letter.count == 0 {
            heightConstraint.constant = 10.0
            widthConstraint.constant = 10.0
            circleView.layer.cornerRadius = 5.0
        }
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class StopAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    var color: UIColor
    var letter: String
    init(_ color: UIColor, letter: String, coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.color = color
        self.letter = letter
    }
}
