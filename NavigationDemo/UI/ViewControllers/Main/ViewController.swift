//
//  ViewController.swift
//  NavigationDemo
//
//  Created by Jordan.Dixon on 12/10/2017.
//  Copyright © 2017 Mubaloo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ARCL
import CoreData

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var sceneLocationView = SceneLocationView()
    var locationView = LocationDescription()
    var backgroundView: UIView = {
        var view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.0
        return view
    }()
    
    lazy var mapViewController: MapViewController = {
        let mapController = MapViewController()
        mapController.sceneLocationView = sceneLocationView
        return mapController
    }()
    
    override var prefersStatusBarHidden: Bool { return backgroundView.alpha == 1.0 }
    
    var knownNodes = [Location]()
    
    fileprivate var _fetchedResultsController: NSFetchedResultsController<Location>?
    fileprivate var fetchedResultsController: NSFetchedResultsController<Location> {
        if _fetchedResultsController == nil {
            let fetch = Location.allLocationsFetchRequest
            let frc = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: "title", cacheName: nil)
            
            frc.delegate = self
            try? frc.performFetch()
            _fetchedResultsController = frc
        }
        return _fetchedResultsController!
    }
    
    lazy var mapView = mapViewController.view!
    var navigationNodes = [LocationNode]()
    
    var mapConstraints: ViewContraints!
    
    // MARK: Lifecycle
    override var canBecomeFirstResponder: Bool { return true }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == .motionShake {
            if navigationNodes.isEmpty {
                Location.deleteAll()
                locationView.alpha = 0.0
                return
            }
            
            removeCurrentNavigationNodes()
        }
    }
    
    private func removeCurrentNavigationNodes() {
        navigationNodes.forEach { sceneLocationView.removeLocationNode(locationNode: $0) }
        navigationNodes = [LocationNode]()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        updateView()
        becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneLocationView.pause()
    }
}

// MARK: View setup
extension ViewController {
    
    private func setupView() {
        
        addChildViewController(mapViewController)
        
        view.addSubview(sceneLocationView)
        view.addSubview(locationView)
        view.addSubview(backgroundView)
        view.addSubview(mapView)
        
        sceneLocationView.fillSuperview()
        backgroundView.fillSuperview()
        setupMapConstraints()
        mapViewController.didMove(toParentViewController: self)
        
        mapView.layer.cornerRadius = 20
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mapViewTapped)))
        mapView.alpha = 0.7
        mapView.layer.masksToBounds = true
        
        setupLocationView()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneLocationView.addGestureRecognizer(gesture)
    }
    
    private func setupMapConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        let left = mapView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        left.priority = UILayoutPriority(rawValue: 999)
        
        let right = mapView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30)
        
        let top = mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30)
        
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

// MARK: Map Location Handling
extension ViewController {
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        guard let sceneView = recognizer.view as? SceneLocationView else { return }
        
        let touchLocation = recognizer.location(in: sceneView)
        let hitTest = sceneView.hitTest(touchLocation, options: [:])
        
        guard let node = hitTest.first?.node else {
            UIView.animate(withDuration: 0.2) { self.locationView.alpha = 0.0 }
            return
        }
        
        UIView.animate(withDuration: 0.2) { self.locationView.alpha = 1.0 }
        
        let knownNode = knownNodes.first { $0.node.annotationNode == node }
        
        locationView.nameLabel.text = knownNode?.title
        locationView.descriptionLabel.text = knownNode?.about != "" ? knownNode?.about : "No Description"
        locationView.didTapDirections = {
            self.displayDirections(to: knownNode)
        }
        
    }
    
    private func displayDirections(to location: Location?) {
        removeCurrentNavigationNodes()
        guard let location = location else { return }
        mapViewController.generateRoute(for: location) { (polyline) in
            guard let polyline = polyline else { return }
            self.navigationNodes = self.sceneLocationView.nodes(for: polyline)
            self.navigationNodes.forEach { self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0) }
        }
    }
    
    @objc func mapViewTapped() {

        if self.mapConstraints.height.isActive {
            self.mapConstraints.right.constant = 0
            self.mapView.alpha = 1.0
        } else {
            self.mapConstraints.right.constant = -30
            self.mapView.alpha = 0.7
        }
        
        self.mapConstraints.height.isActive = !self.mapConstraints.height.isActive
        self.mapConstraints.width.isActive = !self.mapConstraints.width.isActive
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.2, options: .allowUserInteraction, animations: {
            self.mapView.layoutIfNeeded()
            self.setNeedsStatusBarAppearanceUpdate()
            self.mapViewController.updateView(isSmall: self.mapConstraints.height.isActive)
            self.backgroundView.alpha = self.mapViewController.searchBar.alpha
        }, completion: nil)
    }
    
}

// MARK: NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateView()
    }
    
    func updateView() {
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            knownNodes.forEach { sceneLocationView.removeLocationNode(locationNode: $0.node) }
            knownNodes = [Location]()
            return
        }
        
        let knownIDs = knownNodes.map { $0.identifier }
        let potentialNewNodes = fetchedResultsController.fetchedObjects?.filter { location in
            !knownIDs.contains { location.identifier == $0 }
        }
        guard let newNodes = potentialNewNodes else { return }
        
        knownNodes.append(contentsOf: newNodes)
        
        knownNodes.forEach {
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0.node)
        }
    }
}
