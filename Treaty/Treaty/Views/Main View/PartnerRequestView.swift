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
                VStack {
                    Text("You have a partner request from: ")
                        .font(.custom(ubuntu, size: 30, relativeTo: .title))
                    Text("@\(viewModel.partnerRequests[0].receiverUsername)")
                        .foregroundColor(colorScheme == .light ? Color.blue : Color.yellow)
                        .font(.custom(ubuntu, size: 30, relativeTo: .title))
                }
                HStack {
                    Button(action: {
                        viewModel.acceptPartnerRequest(at: 0)
                        viewModel.dismiss()
                    }) {
                        Text("Accept")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 40)
                            .fillView(Color("Blue"))
                    }
                    .foregroundColor(.white)
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
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 40)
                            .fillView(Color("Sand"))
                    }
                    .foregroundColor(.white)
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
        .frame(maxWidth: .infinity)
        .padding(15)
    }
}

class PartnerRequestViewModel: ObservableObject {
    @Published var partnerRequests = [PartnerRequestModel]()
    @Environment(\.presentationMode) var presentationMode
    @State var receiverUsername: String = ""
    
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
                    self.receiverUsername = receiverUsername
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
            if error != nil {
                print("Error adding partner to user document: (error)")
                return
            }
            // Update the other user's document to have the current user's UID added to their "partners" field
            Firestore.firestore().collection("Users").document(senderUID).updateData([
                "partners": receiverUID!
            ]) { (error) in
                if error != nil {
                    print("Error adding partner to other user document: (error)")
                    return
                }
                // Delete the partner request in Firestore
                guard let id = partnerRequest.id else { return }
                Firestore.firestore().collection("PartnerRequests").document(id).delete { (error) in
                    if error != nil {
                        print("Error deleting partner request: (error)")
                        return
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.dismiss()
                }
            }
        }
        fetchPartnerRequests()
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
        fetchPartnerRequests()
    }
    
    func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    }
}
