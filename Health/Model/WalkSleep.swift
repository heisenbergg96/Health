//
//  Walk.swift
//  Health
//
//  Created by Vikhyath on 25/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import CoreMotion

class WalkSleep {
    
    var duration: Double
    var steps: Int
    var date: Date
    
    init(duration: Double, steps: Int, date: Date) {
        self.duration = duration
        self.steps = steps
        self.date = date
    }
}
