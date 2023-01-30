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
    init(id: String?, username: String, userUID: String, userEmail: String, userProfileURL: URL, partner: PartnerModel? = nil) {
        self.id = id
        self.username = username
        self.userUID = userUID
        self.userEmail = userEmail
        self.userProfileURL = userProfileURL
        self.partner = partner
    }

    func toDict() -> [String: Any] {
            return [
                "username": username,
                "userUID": userUID,
                "userEmail": userEmail,
                "userProfileURL": userProfileURL
            ]
        }
    
    enum CodingKeys: CodingKey {
        case id
        case username
        case userUID
        case userEmail
        case userProfileURL
        case partner
    }
}
