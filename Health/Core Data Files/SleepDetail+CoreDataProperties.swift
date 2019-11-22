//
//  SleepDetail+CoreDataProperties.swift
//  
//
//  Created by Vikhyath on 11/10/18.
//
//

import Foundation
import CoreData
import UIKit

extension SleepDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepDetail> {
        return NSFetchRequest<SleepDetail>(entityName: "SleepDetail")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var duration: Int32
    
    static func deleteObject() {
        
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let request = NSFetchRequest<SleepDetail>(entityName: "SleepDetail")
        
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
    
    static func insertObjects(sleepObject: WalkSleep) {
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        let entity = NSEntityDescription.insertNewObject(forEntityName: "SleepDetail", into: context) as? SleepDetail
        entity?.date = sleepObject.date as NSDate?
        entity?.duration = Int32(sleepObject.steps)
        do {
            try context.save()
        } catch {
            print("error")
        }
    }
    
    static func fetchSleepDetail() -> [WalkSleep] {
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return [WalkSleep]()
        }
        var sleepDetails: [WalkSleep] = []
        let request = NSFetchRequest<SleepDetail>(entityName: "SleepDetail")
        request.returnsObjectsAsFaults = false
        do {
            let sleepHistory = try context.fetch(request)
            for sleep in sleepHistory {
                guard let date = sleep.date as Date? else {
                    return [WalkSleep]()
                }
                sleepDetails.append(WalkSleep(duration: 0, steps: Int(sleep.duration), date: date))
            }
            
        } catch {
            print("Error fetching data from coredata!")
        }
        return sleepDetails
    }
}
