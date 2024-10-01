//
//  Item.swift
//  TimeLog
//
//  Created by Aybars Nazlica on 2024/10/01.
//

import Foundation
import SwiftData

@Model
final class Item {
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval? // Duration in seconds
    
    init(startTime: Date, endTime: Date? = nil, duration: TimeInterval? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
    }
}
