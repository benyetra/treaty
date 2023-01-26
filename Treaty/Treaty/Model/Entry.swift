//
//  Tasks.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/22/23.
//

import SwiftUI
import FirebaseFirestoreSwift

// Entry Model
struct Entry: Identifiable{
    @DocumentID var id: String?
    var product: String
    var taskParticipants: [User]
    var taskDate: Date
}


