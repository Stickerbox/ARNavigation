//
//  LocationTag.swift
//  NavigationDemo
//
//  Created by Jordan.Dixon on 12/10/2017.
//  Copyright © 2017 Mubaloo. All rights reserved.
//

import UIKit
import CoreLocation
import ARCL

class LocationTag {
    
    static func view(named name: String, icon: String) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 105, height: 45))

        view.backgroundColor = UIColor(hex: "f4f4f4")
        view.layer.cornerRadius = 20
        view.layer.borderColor = UIColor(hex: "e5e5e5").cgColor
        view.layer.borderWidth = 1
        
        let emoji = UILabel()
        emoji.text = icon
        emoji.font = UIFont.systemFont(ofSize: 18)
        emoji.textAlignment = .center
        view.addSubview(emoji)
        emoji.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, topConstant: 5, leftConstant: 10, bottomConstant: 5, rightConstant: 0, widthConstant: 25, heightConstant: 25)
        
        let label = UILabel()
        label.text = name
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 11)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.textColor = UIColor(hex: "1c1c1c")
        view.addSubview(label)
        label.anchor(top: view.topAnchor, left: emoji.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 5, rightConstant: 5, widthConstant: nil, heightConstant: nil)

        return view
    }
    
}
