//
//  AutoLayout+Extensions.swift
//  NavigationDemo
//
//  Created by Jordan.Dixon on 12/10/2017.
//  Copyright © 2017 Mubaloo. All rights reserved.
//

import UIKit

//MARK: NibInflatable
protocol NibInflatable: class {
    
    var container: UIView! { get }
    var nibName: String { get }
    func initializeSubviews()
}

extension NibInflatable where Self: UIView {
    
    var nibName: String {
        return String(describing: type(of: self))
    }
    
    func initializeSubviews() {
        let nib = UINib(nibName: nibName, bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        addSubview(container)
        container.fillSuperview()
    }
}

// MARK: NSLayoutConstraintHelpers
extension UIView {
    
    private func removeConstraints() {
        
        NSLayoutConstraint.deactivate(self.constraints)
        
        guard let superview = superview else { return }
        self.removeFromSuperview()
        superview.addSubview(self)
    }
    
    public func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }
    
    public func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat? = nil, heightConstant: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        
        anchorWithReturnAnchors(top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant, widthConstant: widthConstant, heightConstant: heightConstant)
    }

    public func anchorWidth(to size: CGFloat) -> NSLayoutConstraint {
        let anchor = widthAnchor.constraint(equalToConstant: size)
        anchor.isActive = true
        return anchor
    }
    
    public func anchorHeight(to size: CGFloat) -> NSLayoutConstraint {
        let anchor = heightAnchor.constraint(equalToConstant: size)
        anchor.isActive = true
        return anchor
    }
    
    @discardableResult
    public func anchorWithReturnAnchors(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat? = nil, heightConstant: CGFloat? = nil) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if let widthConstant = widthConstant {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if let heightConstant = heightConstant {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach { $0.isActive = true }
        
        return anchors
    }
    
    public func anchorCenterXToSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    public func anchorCenterYToSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    public func anchorCenterSuperview() {
        anchorCenterXToSuperview()
        anchorCenterYToSuperview()
    }
}

