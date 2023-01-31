//
//  PartnerRequestView.swift
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
    @EnvironmentObject var userWrapper: UserWrapper
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack {
            if viewModel.partnerRequests.count > 0 {
                Text("You have a partner request")
                HStack {
                    Button(action: {
                        viewModel.acceptPartnerRequest(at: 0)
                        viewModel.dismiss()
                    }) {
                        Text("Accept")
                            .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                            .hAlign(.center)
                            .fillView(colorScheme == .light ? Color.black : Color.white)
                    }.foregroundColor(.white)
                        .padding(.horizontal,50)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.black)
                        }
                        .padding(.top,10)
                    Button(action: {
                        viewModel.declinePartnerRequest(at: 0)
                        viewModel.dismiss()
                    }) {
                        Text("Decline")
                            .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                            .hAlign(.center)
                            .fillView(colorScheme == .light ? Color.black : Color.white)
                    }.foregroundColor(.white)
                        .padding(.horizontal,50)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.black)
                        }
                        .padding(.top,10)
                }
            } else {
                Text("No partner requests")
            }
        }
    }
}

class PartnerRequestViewModel: ObservableObject {
    @Published var partnerRequests = [PartnerRequestModel]()
    @Environment(\.presentationMode) var presentationMode
    
    init() {
        fetchPartnerRequests()
    }
    
    func fetchPartnerRequests() {
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser?.uid ?? ""
        
        db.collection("PartnerRequests").whereField("receiverUID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
            } else {
                var partnerRequests: [PartnerRequestModel] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let senderUsername = data["senderUsername"] as! String
                    let receiverUsername = data["receiverUsername"] as! String
                    let senderUID = data["senderUID"] as! String
                    let receiverUID = data["receiverUID"] as! String
                    let partnerRequest = PartnerRequestModel(id: document.documentID, senderUsername: senderUsername,
                                                             receiverUsername: receiverUsername, senderUID: senderUID, receiverUID: receiverUID)
                    partnerRequests.append(partnerRequest)
                    self.partnerRequests = partnerRequests
                }
                if self.partnerRequests.count == 0 {
                    self.dismiss()
                }
            }
        }
    }
    
    
    func acceptPartnerRequest(at index: Int) {
        let partnerRequest = partnerRequests[index]
        let senderUID = partnerRequest.senderUID
        let receiverUID = Auth.auth().currentUser?.uid
        // Update the user document to have the partner's UID added to the "partners" field
        Firestore.firestore().collection("Users").document(receiverUID!).updateData([
            "partners": senderUID
        ]) { (error) in
            if let error = error {
                print("Error adding partner to user document: (error)")
                return
            }
            // Update the other user's document to have the current user's UID added to their "partners" field
            Firestore.firestore().collection("Users").document(senderUID).updateData([
                "partners": receiverUID!
            ]) { (error) in
                if let error = error {
                    print("Error adding partner to other user document: (error)")
                    return
                }
                // Delete the partner request in Firestore
                guard let id = partnerRequest.id else { return }
                Firestore.firestore().collection("PartnerRequests").document(id).delete { (error) in
                    if let error = error {
                        print("Error deleting partner request: (error)")
                        return
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.dismiss()
                }
            }
        }
    }
    
    func declinePartnerRequest(at index: Int) {
        let partnerRequest = partnerRequests[index]
        guard let id = partnerRequest.id else { return }
        // Delete the partner request in Firestore
        Firestore.firestore().collection("PartnerRequests").document(id).delete { (error) in
            if let error = error {
                print("Error deleting partner request: \(error)")
                return
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss()
        }
    }
    
    func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    }
}
