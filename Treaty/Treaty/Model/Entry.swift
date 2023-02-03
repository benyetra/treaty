//
//  Tasks.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/22/23.
//

import SwiftUI
import FirebaseFirestoreSwift

// Entry Model
struct Entry: Identifiable,Codable{
    @DocumentID var id: String?
    var product: String
    var amountSpent: Int
    var taskParticipants: [User]
    var taskDate: Date
    var userUID: String
    
    enum CodingKeys: CodingKey {
        case id
        case product
        case amountSpent
        case taskParticipants
        case taskDate
        case userUID
    }
    
    func getDate(offset: Int)->Date{
        let calender = Calendar.current
        
        let date = calender.date(byAdding: .day, value: offset, to: Date())
        
        return date ?? Date()
    }
}


