//
//  WalkTask.swift
//  Health
//
//  Created by Vikhyath on 24/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation

struct WalkTask {
    
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval
    
    init(startTime: Date, endTime: Date) {
        self.startTime = startTime
        self.endTime = endTime
        self.duration = startTime.timeIntervalSince(endTime)
    }
}
