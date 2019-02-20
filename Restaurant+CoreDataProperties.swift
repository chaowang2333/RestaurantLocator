//
//  Restaurant+CoreDataProperties.swift
//  Ass1_Restaurant
//
//  Created by crow on 6/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import Foundation
import CoreData


extension Restaurant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Restaurant> {
        return NSFetchRequest<Restaurant>(entityName: "Restaurant")
    }

    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var logo: NSData?
    @NSManaged public var dateAdded: NSDate?
    @NSManaged public var rating: Int32
    @NSManaged public var address: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var notification: Bool
    @NSManaged public var radius: Int32
    @NSManaged public var rownum: Int32
    @NSManaged public var photos: NSObject?
    @NSManaged public var placeMark: NSObject?

}
