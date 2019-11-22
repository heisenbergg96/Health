//
//  NewsArticle+CoreDataProperties.swift
//  
//
//  Created by Vikhyath on 11/10/18.
//
//

import Foundation
import CoreData
import UIKit

extension NewsArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsArticle> {
        return NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
    }

    @NSManaged public var detailednews: String?
    @NSManaged public var image: NSData?
    @NSManaged public var title: String?
    
    
    static func deleteObject() {
        
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.newBackgroundContext()
        let request = NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
        
        do {
            guard let obj = try context?.fetch(request) else {
                return
            }
            for item in obj {
                context?.delete(item)
            }
            try context?.save()
        } catch {
            print("error deleting records!")
        }
    }
    
    static func insertArticle(object: Article) {
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.newBackgroundContext() else {
            return
        }
        let entity = NSEntityDescription.insertNewObject(forEntityName: "NewsArticle", into: context) as? NewsArticle
        entity?.title = object.title
        entity?.detailednews = object.description
        do {
            try context.save()
        } catch {
            print("error")
        }
    }
    
    static func fetchNewsDetails() -> [Article] {
        
        var newsArticles: [Article] = []
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return [Article]()
        }
        
        let request = NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
        request.returnsObjectsAsFaults = false
        
        do {
            let articles = try context.fetch(request)
            for article in articles {
                if let articletitle = article.title, let articledescription = article.detailednews {
                    newsArticles.append(Article(title: articletitle, description: articledescription, urlToImage: "none", url: "none"))
                }
            }
        } catch {
            print("error fetching news from coredata")
        }
        return newsArticles
    }
}
