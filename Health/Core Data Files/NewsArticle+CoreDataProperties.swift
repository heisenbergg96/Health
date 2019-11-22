//
//  NewsArticle+CoreDataProperties.swift
//  
//
//  Created by Vikhyath on 11/10/18.
//
//

import Foundation
import CoreData

extension NewsArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsArticle> {
        return NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
    }

    @NSManaged public var detailednews: String?
    @NSManaged public var image: NSData?
    @NSManaged public var title: String?

}
