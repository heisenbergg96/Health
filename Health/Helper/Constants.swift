//
//  Constants.swift
//  Health
//
//  Created by Vikhyath on 01/10/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
    
    static let brightOrange = UIColor(red: 255.0 / 255.0, green: 69.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
    static let red = UIColor(red: 255.0 / 255.0, green: 115.0 / 255.0, blue: 115.0 / 255.0, alpha: 1.0)
    static let orange = UIColor(red: 245.0 / 255.0, green: 139.0 / 255.0, blue: 68.0 / 255.0, alpha: 1.0)
    static let blue = UIColor(red: 76.0 / 255.0, green: 196.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static let green = UIColor(red: 34.0 / 255.0, green: 139.0 / 255.0, blue: 34.0 / 255.0, alpha: 1.0)
    static let darkGrey = UIColor(red: 85.0 / 255.0, green: 85.0 / 255.0, blue: 85.0 / 255.0, alpha: 1.0)
    static let veryDarkGrey = UIColor(red: 13.0 / 255.0, green: 13.0 / 255.0, blue: 13.0 / 255.0, alpha: 1.0)
    static let lightGrey = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
    static let black = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
    static let white = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static let lightBlue = UIColor(red: 113.0 / 155.0, green: 198.0 / 255.0, blue: 192.0 / 255.0, alpha: 1.0)
    static let lightorange = UIColor(red: 245.0 / 255.0, green: 139.0 / 255.0, blue: 68.0 / 255.0, alpha: 0.3)
    static let progressBlue = UIColor(red: 76.0 / 255.0, green: 196.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.7)
}

struct Urls {
    
    static let firebaseUrl = "https://health-d776c.firebaseio.com"
    static let userurl = "https://health-d776c.firebaseio.com/Users"
    static let newUrl = "https://newsapi.org/v2/top-headlines?country=gb&category=health&apiKey=cd3ec0f787d44f0394e68b8fa111b4f7"
}

struct Keys {
    
    static let walk = "Walk"
    static let sleep = "Sleep"
    static let activity = "Activities"
    static let date = "date"
    static let duration = "duration"
    static let steps = "steps"
    static let goal = "goal"
    static let sleepgoal = "sleepgoal"
    static let walkgoal = "walkgoal"
    static let name = "name"
    
}
