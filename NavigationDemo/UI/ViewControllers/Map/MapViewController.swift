//
//  MapViewController.swift
//  NavigationDemo
//
//  Created by Jordan.Dixon on 12/10/2017.
//  Copyright © 2017 Mubaloo. All rights reserved.
//

import UIKit
import MapKit
import ARCL
import CoreData

class MapViewController: UIViewController {
    
    let map = MKMapView()
    let locationManager = CLLocationManager()
    let searchBar = UISearchBar()
    let addButton = AddButton()
    let locationButton = LocationButton()
    var sceneLocationView: SceneLocationView!
    
    var didUpdateLocation: ((CLLocation?) -> Void)?
        
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
    
    override func viewDidLoad() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        
        view.addSubview(map)
        view.addSubview(searchBar)
        view.addSubview(addButton)
        view.addSubview(locationButton)
        
        map.fillSuperview()
        map.showsUserLocation = true
        map.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(mapDidLongPress)))
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let currentLocation = CLLocationCoordinate2DMake(locationManager.location?.coordinate.latitude ?? 0.0, locationManager.location?.coordinate.longitude ?? 0.0)
        let region = MKCoordinateRegionMake(currentLocation, span)
        map.setRegion(region, animated: true)
        
        searchBar.anchor(top: map.topAnchor, left: map.leftAnchor, bottom: nil, right: map.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: nil, heightConstant: nil)
        addButton.anchor(top: nil, left: nil, bottom: map.bottomAnchor, right: map.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 15, rightConstant: 15, widthConstant: nil, heightConstant: nil)
        locationButton.anchor(top: nil, left: map.leftAnchor, bottom: map.bottomAnchor, right: nil, topConstant: 0, leftConstant: 15, bottomConstant: 15, rightConstant: 0, widthConstant: nil, heightConstant: nil)
        
        searchBar.barStyle = .default
        searchBar.placeholder = "Search"
        updateView(isSmall: true)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        
        updateView()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        locationManager.stopUpdatingHeading()
    }
    
    @objc func mapDidLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began { return }
        
        let touch = gesture.location(in: map)
        let coordinate = map.convert(touch, toCoordinateFrom: map)
        presentAlert(lat: coordinate.latitude, long: coordinate.longitude)
    }
    
    @objc func addButtonTapped() {
        presentAlert()
    }
    
    @objc func locationButtonTapped() {
        locationManager.startUpdatingHeading()
    }
    
    private func presentAlert(lat: Double? = nil, long: Double? = nil) {
        let alert = UIAlertController(title: "Add Point", message: "", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Emoji" }
        alert.addTextField { $0.placeholder = "Title" }
        alert.addTextField { $0.placeholder = "Description" }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            
            let textFields = alert.textFields!
            let lat = lat ?? self.locationManager.location?.coordinate.latitude
            let long = long ?? self.locationManager.location?.coordinate.longitude
            
            let _ = Location.new(title: textFields[1].text, emoji: textFields[0].text, about: textFields[2].text, latitude: lat, longitude: long, altitude: self.locationManager.location?.altitude)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func updateView(isSmall: Bool) {
        searchBar.alpha = isSmall ? 0.0 : 1.0
        addButton.alpha = isSmall ? 0.0 : 1.0
        locationButton.alpha = isSmall ? 0.0 : 1.0
    }
}

extension MapViewController {
    
    func generateRoute(for location: Location, completion: @escaping ((MKPolyline?) -> Void)) {
        guard let source = locationManager.location?.coordinate else { completion(nil); return }
        let destination = location.node.location.coordinate
        
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response,
                let route = response.routes.first else { completion(nil); return }
            
            completion(route.polyline)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let camera = map.camera
        camera.heading = newHeading.magneticHeading
        map.setCamera(camera, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocation?(manager.location)
    }
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateView()
    }
    
    func updateView() {
        if fetchedResultsController.fetchedObjects?.count == 0 {
            let annotations = map.annotations
            annotations.forEach { map.removeAnnotation($0) }
            return
        }
        
        fetchedResultsController.fetchedObjects?.forEach { location in
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            
            annotation.coordinate = coordinate
            annotation.title = location.title
            annotation.subtitle = location.about
            map.addAnnotation(annotation)
        }
    }
}
