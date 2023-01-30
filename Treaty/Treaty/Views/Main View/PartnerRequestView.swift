//
//  PartnerRequestViwe.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/30/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct PartnerRequestView: View {
  @ObservedObject var viewModel: PartnerRequestViewModel

  var body: some View {
    VStack {
      if viewModel.partnerRequests.count > 0 {
        Text("You have a partner request")
        HStack {
          Button(action: {
            viewModel.acceptPartnerRequest(at: 0)
          }) {
            Text("Accept")
          }
          Button(action: {
            viewModel.declinePartnerRequest(at: 0)
          }) {
            Text("Decline")
          }
        }
      } else {
        Text("No partner requests")
      }
    }
  }
}

class PartnerRequestViewModel: ObservableObject {
    @Published var partnerRequests = [PartnerRequestModel]()

  init() {
    fetchPartnerRequest()
  }
  
  func fetchPartnerRequest() {
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser?.uid ?? ""
    
    db.collection("Users").document(userID).collection("PartnerRequests").addSnapshotListener { (querySnapshot, error) in
        if let error = error {
            print("Error fetching documents: \(error)")
        } else {
            self.partnerRequests = querySnapshot?.documents.map { PartnerRequestModel(dictionary: $0.data()) } ?? []
        }
    }
  }

  func acceptPartnerRequest(at index: Int) {
    // Code to accept the partner request in Firestore
    let partnerRequest = partnerRequests[index]
    // ...
  }
  
  func declinePartnerRequest(at index: Int) {
    // Code to decline the partner request in Firestore
    let partnerRequest = partnerRequests[index]
    // ...
  }
}
