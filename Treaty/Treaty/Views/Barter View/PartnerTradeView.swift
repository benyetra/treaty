//
//  PartnerTradeView.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/4/23.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import Firebase
struct PartnerTradeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var userWrapper: UserWrapper
    @EnvironmentObject var entryModel: EntryViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: Task Values
    @State var selectedUsers = [User]()
    @State var selectedType: String = ""
    @State var selectedAmount: Int = 0
    @State var product: String = ""
    @State var taskParticipants: String = ""
    @State var taskDate: Date = Date()
    @State private var isButton1Selected = false
    @State private var isButton2Selected = false
    @State private var selectedButton = -1
    @State var selectedIndex: Int? = nil
    @State private var partnerUser: User?
    @State private var partnerModel: PartnerModel?
    @State var partnerUsername: String = ""
    @State private var partnerProfileURL: String = ""
    @Binding var selectedTransaction: TransactionType
    var user: User

    init(userWrapper: UserWrapper, selectedTransaction: Binding<TransactionType>) {
        self.userWrapper = userWrapper
        self.user = userWrapper.user
        self._selectedTransaction = selectedTransaction
    }
    
    
    var body: some View {
        NavigationView{
            List{
                Section {
                    HStack {
                        HStack {
                            if let transaction = self.selectedTransaction {
                                HStack {
                                    Image(transaction.productIcon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                    Text("\(transaction.product)")
                                }
                                .frame(maxWidth: .infinity,alignment: .leading)

                                if userWrapper.partner != nil {
                                    HStack {
                                        if let amountSpent = transaction.amountSpent {
                                            Text("\(amountSpent)")
                                        }
                                        Image("treat")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            } else {
                                Text("No transaction selected")
                            }
                        }
                    }
                } header: {
                    Text("Completed Task")
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                }
                
                Section {
                    Group {
                        HStack {
                            if userWrapper.partner != nil {
                                if let userProfileURL = userWrapper.partner?.userProfileURL {
                                    WebImage(url: userProfileURL).placeholder {
                                        Image("NullProfile")
                                            .resizable()
                                    }
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                                }
                                if let username = userWrapper.partner?.username {
                                    Text("@\(username)")
                                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                                }
                            } else {
                                Text("No partner currently linked. If you have a partner add them on the Profile screen.")
                                    .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                            }
                        }
                    }
                } header: {
                    Text("Your Partner")
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                }
                
                
                Section {
                    DatePicker("", selection: $taskDate)
                        .datePickerStyle(.graphical)
                } header: {
                    Text("Task Date")
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Give Partner Credit")
            .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
            .navigationBarTitleDisplayMode(.inline)
            // MARK: Disabling Dismiss on Swipe
            .interactiveDismissDisabled()
            // MARK: Action Buttons
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel"){
                        dismiss()
                    }.foregroundColor(Color.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save"){
                        save()
                        userWrapper.partner?.addCredits(amount: self.selectedTransaction.amountSpent)
                        userWrapper.user.removeCredits(amount: self.selectedTransaction.amountSpent)
                        entryModel.filterTodayEntries(userUID: user.userUID)
                        print("Array count: \(self.selectedUsers.count)")
                    }
                    .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                }
            }
        }
    }
    
    func save(){
        if let partner = self.userWrapper.partner {
            self.selectedUsers.append(User(id: "", username: partner.username, userUID: "", userEmail: "", userProfileURL: partner.userProfileURL, token: partner.token, credits: partner.credits))
        }
        let newEntry = Entry(id: UUID().uuidString, product: self.selectedTransaction.product, amountSpent: self.selectedTransaction.amountSpent, taskParticipants: self.selectedUsers, taskDate: self.taskDate, userUID: user.userUID)
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        var taskParticipants = [[String: Any]]()
        for user in newEntry.taskParticipants {
            taskParticipants.append(["username": user.username, "userProfileURL": user.userProfileURL.absoluteString])
        }
        ref = db.collection("entries").addDocument(data: [
            "id": newEntry.id,
            "product": newEntry.product,
            "amountSpent": newEntry.amountSpent,
            "taskParticipants": taskParticipants,
            "taskDate": newEntry.taskDate,
            "userUID": newEntry.userUID
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        self.dismiss()
    }
}
