//
//  RecipeData+CoreDataProperties.swift
//  GoTo
//
//  Created by Ashley Smith on 5/17/22.
//
//

import Foundation
import CoreData


extension RecipeData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeData> {
        return NSFetchRequest<RecipeData>(entityName: "RecipeData")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var imageData: NSData?
    @NSManaged public var name: String?
    @NSManaged public var urlString: String?

}

extension RecipeData : Identifiable {

}
