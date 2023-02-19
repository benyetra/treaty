//
//  PetModel.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/19/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase
import FirebaseFirestore

struct PetModel: Identifiable,Codable{
    @DocumentID var id: String?
    var name: String
    var breed: String
    var birthDate: Date
    var weight: Int
    
    enum CodingKeys: CodingKey {
        case name
        case breed
        case birthDate
        case weight
    }
}
