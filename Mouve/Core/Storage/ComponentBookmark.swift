//
//  ComponentBookmark.swift
//  Mouve
//
//  Created by Salman Alfarisi on 17/09/26.
//

import Foundation
import SwiftData

@Model
public final class ComponentBookmark {
    public var componentId: String
    public var bookmarkedAt: Date
    public var notes: String

    public init(
        componentId: String,
        bookmarkedAt: Date = Date(),
        notes: String = ""
    ) {
        self.componentId = componentId
        self.bookmarkedAt = bookmarkedAt
        self.notes = notes
    }
}
