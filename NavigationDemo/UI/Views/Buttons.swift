//
//  Buttons.swift
//  NavigationDemo
//
//  Created by Jordan.Dixon on 13/10/2017.
//  Copyright © 2017 Mubaloo. All rights reserved.
//

import UIKit

class AddButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override var intrinsicContentSize: CGSize { return CGSize(width: 60, height: 60) }
    
    private func customInit() {
        backgroundColor = .darkGray
        tintColor = .white
        setImage(UIImage(named: "plus"), for: .normal)
        layer.cornerRadius = 30
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
}

class LocationButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override var intrinsicContentSize: CGSize { return CGSize(width: 60, height: 60) }
    
    private func customInit() {
        backgroundColor = .white
        tintColor = .darkGray
        setImage(UIImage(named: "navigation"), for: .normal)
        imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
        layer.cornerRadius = 30
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
}
