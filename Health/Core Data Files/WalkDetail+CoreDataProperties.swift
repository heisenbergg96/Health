//
//  WalkDetail+CoreDataProperties.swift
//  
//
//  Created by Vikhyath on 11/10/18.
//
//

import Foundation
import CoreData
import UIKit

extension WalkDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalkDetail> {
        return NSFetchRequest<WalkDetail>(entityName: "WalkDetail")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var steps: Int32
    
    static func deleteObject() {
        
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let request = NSFetchRequest<WalkDetail>(entityName: "WalkDetail")
        
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
    
    static func insertObjects(walkObject: WalkSleep) {
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        let entity = NSEntityDescription.insertNewObject(forEntityName: "WalkDetail", into: context) as? WalkDetail
        entity?.date = walkObject.date as NSDate?
        entity?.steps = Int32(walkObject.steps)
        do {
            try context.save()
        } catch {
            print("error")
        }
    }
    
    static func fetchWalkDetail() -> [WalkSleep] {
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return [WalkSleep]()
        }
        var sleepDetails: [WalkSleep] = []
        let request = NSFetchRequest<WalkDetail>(entityName: "WalkDetail")
        request.returnsObjectsAsFaults = false
        do {
            let walkHistory = try context.fetch(request)
            for walk in walkHistory {
                guard let date = walk.date as Date? else {
                    return [WalkSleep]()
                }
                sleepDetails.append(WalkSleep(duration: 0, steps: Int(walk.steps), date: date))
            }
        } catch {
            print("Error fetching data from coredata!")
        }
        return sleepDetails
    }
}
