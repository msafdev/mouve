//
//  Item.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
