//
//  LocationDescription.swift
//  NavigationDemo
//
//  Created by Jordan.Dixon on 12/10/2017.
//  Copyright © 2017 Mubaloo. All rights reserved.
//

import UIKit

class LocationDescription: UIView, NibInflatable {
    
    @IBOutlet var container: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet weak var directionsButton: UIButton!
    var didTapDirections: (() -> Void)?
    
    @IBAction func directionsTapped() {
        didTapDirections?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    private func customInit() {
        initializeSubviews()
        directionsButton.tintColor = .white
    }
}
