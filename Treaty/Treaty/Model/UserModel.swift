//
//  UserModel.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI
import FirebaseFirestoreSwift

class User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var userUID: String
    var userEmail: String
    var userProfileURL: URL
    var partner: PartnerModel?
    var token: String?
    var credits: Int

    func addCredits(amount: Int) {
        credits += amount
    }

    func removeCredits(amount: Int) {
        credits -= amount
    }

    func getTotalCredits() -> Int {
        return credits
    }

    init(id: String?, username: String, userUID: String, userEmail: String, userProfileURL: URL, partner: PartnerModel? = nil, token: String?, credits: Int) {
        self.id = id
        self.username = username
        self.userUID = userUID
        self.userEmail = userEmail
        self.userProfileURL = userProfileURL
        self.partner = partner
        self.token = token
        self.credits = credits
    }

    func toDict() -> [String: Any] {
        return [
            "username": username,
            "userUID": userUID,
            "userEmail": userEmail,
            "userProfileURL": userProfileURL,
            "token": token,
            "credits": credits
        ]
    }

    enum CodingKeys: CodingKey {
        case id
        case username
        case userUID
        case userEmail
        case userProfileURL
        case partner
        case token
        case credits
    }
}


