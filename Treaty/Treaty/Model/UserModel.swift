//
//  UserModel.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI
import FirebaseFirestoreSwift

struct User: Identifiable,Codable {
    @DocumentID var id: String?
    var username: String
    var userUID: String
    var userEmail: String
    var userProfileURL: URL
    var partner: PartnerModel?

    
    enum CodingKeys: CodingKey {
        case id
        case username
        case userUID
        case userEmail
        case userProfileURL
        case partner
    }
}
