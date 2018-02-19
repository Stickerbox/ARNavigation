//
//  ARViewController+Constraints.swift
//  NavigationDemo
//
//  Created by Jordan.Dixon on 19/02/2018.
//  Copyright © 2018 Mubaloo. All rights reserved.
//

import UIKit

extension ARViewController {

    override func updateViewConstraints() {
        sceneLocationView.fillSuperview()
        backgroundView.fillSuperview()
        setupMapConstraints()
        setupLocationView()
        super.updateViewConstraints()
    }

    private func setupMapConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        let left = mapView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        left.priority = UILayoutPriority(rawValue: 999)

        let right = mapView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30)

        let top = mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.safeAreaInsets.top)

        let bottom = mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        bottom.priority = UILayoutPriority(rawValue: 999)

        let width = mapView.widthAnchor.constraint(equalToConstant: 150)
        let height = mapView.heightAnchor.constraint(equalToConstant: 150)

        NSLayoutConstraint.activate([left, right, top, bottom, width, height])

        self.mapConstraints = ViewContraints(left: left, right: right, top: top, bottom: bottom, width: width, height: height)
    }

    private func setupLocationView() {
        locationView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 15, rightConstant: 15, widthConstant: nil, heightConstant: nil)
        locationView.layer.masksToBounds = true
        locationView.layer.cornerRadius = 20
        locationView.layer.borderWidth = 1
        locationView.layer.borderColor = UIColor.darkGray.cgColor
        locationView.alpha = 0.0
    }
}
