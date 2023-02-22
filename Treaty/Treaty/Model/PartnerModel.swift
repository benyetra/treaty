//
//  PartnerModel.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/24/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase
import FirebaseFirestore

struct PartnerModel:Codable {
    var username: String
    var userProfileURL: URL
    var token: String
    var credits: Int
    var partnerUID: String
    var pet: PetModel?
    
    func addCredits(amount: Int) {
        let db = Firestore.firestore()
        let partnerRef = db.collection("Users").document(partnerUID)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let partnerData = try transaction.getDocument(partnerRef)
                guard var partner = partnerData.data() else {
                    return nil
                }
                let oldCredits = partner["credits"] as? Int ?? 0
                partner["credits"] = oldCredits + amount
                transaction.setData(partner, forDocument: partnerRef)
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
        let partnerRef = db.collection("Users").document(partnerUID)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let partnerData = try transaction.getDocument(partnerRef)
                guard var partner = partnerData.data() else {
                    return nil
                }
                let oldCredits = partner["credits"] as? Int ?? 0
                partner["credits"] = oldCredits - amount
                transaction.setData(partner, forDocument: partnerRef)
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
}



