//
//  PartnerRequestModel.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/30/23.
//

import SwiftUI
import FirebaseFirestoreSwift

struct PartnerRequestModel: Identifiable,Codable {
    @DocumentID var id: String?
    let senderUsername: String
    let receiverUsername: String
    let senderUID: String
    let receiverUID: String
    
    init(id: String?, senderUsername: String, receiverUsername: String, senderUID: String, receiverUID: String) {
        self.id = id
        self.senderUsername = senderUsername
        self.receiverUsername = receiverUsername
        self.senderUID = senderUID
        self.receiverUID = receiverUID
    }
}
