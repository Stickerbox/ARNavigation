//
//  Location+CoreDataProperties.swift
//  NavigationDemo
//
//  Created by Jordan.Dixon on 13/10/2017.
//  Copyright © 2017 Mubaloo. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var emoji: String?
    @NSManaged public var title: String?
    @NSManaged public var about: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var altitude: Double
    @NSManaged public var identifier: UUID?

}
