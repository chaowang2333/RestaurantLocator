//
//  Category+CoreDataProperties.swift
//  Ass1_Restaurant
//
//  Created by crow on 5/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var title: String?
    @NSManaged public var icon: NSData?
    @NSManaged public var color: NSObject?
    @NSManaged public var rownum: Int32

}
