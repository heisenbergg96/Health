//
//  DataSource.swift
//  Health
//
//  Created by Vikhyath on 11/10/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataSource {
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func deleteObject(entityName: String) {
    
        let request = NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
            
        do {
            let obj = try context?.fetch(request)
            guard let newsObject = obj else {
                return
            }
            for item in newsObject {
                context?.delete(item)
            }
            try context?.save()
        } catch let error {
            print(error)
        }
    }
    
    
    
}
