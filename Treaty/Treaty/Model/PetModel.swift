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

struct PetModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var birthDate: Date
    var breed: String
    var profileImageURL: URL?
    var weight: Int
    
    private enum CodingKeys: CodingKey {
        case name
        case birthDate
        case breed
        case profileImageURL
        case weight
    }
    
    init(name: String, birthDate: Date, breed: String, profileImageURL: URL?, weight: Int) {
        self.name = name
        self.birthDate = birthDate
        self.breed = breed
        self.profileImageURL = profileImageURL
        self.weight = weight
    }
}



