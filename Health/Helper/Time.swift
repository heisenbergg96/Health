//
//  Time.swift
//  Health
//
//  Created by Vikhyath on 25/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation

extension Date {
    
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
    
    static func stringToDate(str: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let date = dateFormatter.date(from: str) {
            return date
        }
        return Date()
    }
    
    static func dateToString(date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: date)
        
        return dateString
    }
    
    static func getTodaysDate() -> Date {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return date
    }
    
    static func getKeyFromDate() -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        let key = formatter.string(from: date)
        
        return key
    }
    
}
