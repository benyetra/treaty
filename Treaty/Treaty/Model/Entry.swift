//
//  Tasks.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/22/23.
//

import SwiftUI

// Entry Model
struct Entry: Identifiable{
    var id = UUID().uuidString
    var taskTitle: String
    var taskDescription: String
    var taskDate: Date
}

