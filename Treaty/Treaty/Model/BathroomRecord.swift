//
//  BathroomRecord.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/7/23.
//

import SwiftUI
import FirebaseFirestoreSwift

struct BathroomRecord: Identifiable,Codable{
    @DocumentID var id: String?
    var product: String
    var productIcon: String
    var taskDate: Date
    var userUID: String
    var size: String
    
    enum CodingKeys: CodingKey {
        case id
        case product
        case productIcon
        case taskDate
        case userUID
        case size
    }
    
    func getDate(offset: Int)->Date{
        let calender = Calendar.current
        
        let date = calender.date(byAdding: .day, value: offset, to: Date())
        
        return date ?? Date()
    }
}
