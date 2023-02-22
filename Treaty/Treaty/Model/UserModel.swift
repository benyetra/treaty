//
//  UserModel.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase
import FirebaseFirestore

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userUID == rhs.userUID
    }
}

class User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var userUID: String
    var userEmail: String
    var userProfileURL: URL
    var partner: PartnerModel?
    var token: String?
    var credits: Int
    var pet: [PetModel]?

    func addCredits(amount: Int) {
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userUID)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let userData = try transaction.getDocument(userRef)
                guard var user = userData.data() else {
                    return nil
                }
                let oldCredits = user["credits"] as? Int ?? 0
                user["credits"] = oldCredits + amount
                transaction.setData(user, forDocument: userRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
            }
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction succeeded.")
            }
        }
    }

    func removeCredits(amount: Int) {
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userUID)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let userData = try transaction.getDocument(userRef)
                guard var user = userData.data() else {
                    return nil
                }
                let oldCredits = user["credits"] as? Int ?? 0
                user["credits"] = oldCredits - amount
                transaction.setData(user, forDocument: userRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
            }
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction succeeded.")
            }
        }
    }

    func getTotalCredits() -> Int {
        return credits
    }

    init(id: String?, username: String, userUID: String, userEmail: String, userProfileURL: URL, partner: PartnerModel? = nil, token: String?, credits: Int, pet: [PetModel]? = nil) {
            self.id = id
            self.username = username
            self.userUID = userUID
            self.userEmail = userEmail
            self.userProfileURL = userProfileURL
            self.partner = partner
            self.token = token
            self.credits = credits
            self.pet = pet ?? []
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
        case pet
    }
}


