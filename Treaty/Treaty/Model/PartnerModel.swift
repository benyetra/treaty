//
//  PartnerModel.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/24/23.
//

import SwiftUI

struct PartnerModel:Codable {
    var username: String
    var userProfileURL: URL
    var token: String
    var credits: Int
    
    mutating func addCredits(amount: Int) {
        credits += amount
    }

    mutating func removeCredits(amount: Int) {
        credits -= amount
    }

    func getTotalCredits() -> Int {
        return credits
    }
}


