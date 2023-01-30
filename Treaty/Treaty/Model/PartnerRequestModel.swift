//
//  PartnerRequestModel.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/30/23.
//

import SwiftUI

struct PartnerRequestModel {
    let id: String
    let username: String
    let status: Bool

    init(dictionary: [String: Any]) {
        id = dictionary["id"] as? String ?? ""
        username = dictionary["name"] as? String ?? ""
        status = dictionary["status"] as? Bool ?? false
    }
}
