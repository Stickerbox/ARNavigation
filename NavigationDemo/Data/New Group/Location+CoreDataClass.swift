//
//  Location+CoreDataClass.swift
//  NavigationDemo
//
//  Created by Jordan.Dixon on 13/10/2017.
//  Copyright © 2017 Mubaloo. All rights reserved.
//
//

import Foundation
import CoreData
import ARCL
import CoreLocation

@objc(Location)
public class Location: NSManagedObject {

    class var allLocationsFetchRequest: NSFetchRequest<Location> {
        let request: NSFetchRequest<Location> = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        return request
    }
    
    class func new(title: String?, emoji: String?, about: String?, latitude: Double?, longitude: Double?, altitude: Double?) -> Location {
        let location = Location(context: CoreDataStack.shared.mainContext)
        location.title = title
        location.emoji = emoji
        location.about = about
        location.latitude = latitude ?? 0.0
        location.longitude = longitude ?? 0.0
        location.altitude = altitude ?? 100
        location.identifier = UUID()
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {}
        
        return location
    }
    
    class func deleteAll() {
        do {
            guard let locations = Location.fetchAll() else { return }
            for location in locations {
                CoreDataStack.shared.mainContext.delete(location)
                try CoreDataStack.shared.mainContext.save()
            }
        } catch {}
    }
    
    class func fetchAll() -> [Location]? {
        do {
            return try CoreDataStack.shared.mainContext.fetch(allLocationsFetchRequest)
        } catch {
            return nil
        }
    }
    
    var image: UIImage {
        let view = LocationTag.view(named: title ?? "", icon: emoji ?? "❓")
        let image = UIImage(view: view).resizedImage(newSize: CGSize(width: 105, height: 45))
        return image
    }
    
    var _node: LocationAnnotationNode?
    var node: LocationAnnotationNode {
        if _node == nil {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let location = CLLocation(coordinate: coordinate, altitude: 130)
            _node = LocationAnnotationNode(location: location, image: image)
        }
        return _node!
    }

}
