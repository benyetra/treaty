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
    @State private var partnerToken: String = ""
    @State private var partnerUser: User?
    @State private var partnerModel: PartnerModel?
    @State var partnerUsername: String = ""
    @State private var partnerProfileURL: String = ""
    @State var titleText = "appreciates you helping out"
    @State var bodyText = "Your partner apprecaites you for helping with: "
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
                            HStack {
                                Image(self.selectedTransaction.productIcon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                Text("\(self.selectedTransaction.product)")
                            }
                            .frame(maxWidth: .infinity,alignment: .leading)

                            if userWrapper.partner != nil {
                                HStack {
                                    Text("\(self.selectedTransaction.amountSpent)")
                                    Image("treat")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                }
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
                        entryModel.filterTodayEntries(userUID: user.userUID, filter: "both")
                        print("Array count: \(self.selectedUsers.count)")
                    }
                    .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                }
            }
        }
    }
    
    func save(){
        if let partner = self.userWrapper.partner {
            self.selectedUsers.append(User(id: "", username: partner.username, userUID: partner.partnerUID, userEmail: "", userProfileURL: partner.userProfileURL, token: partner.token, credits: partner.credits))
        }
        let newEntry = Entry(id: UUID().uuidString, product: self.selectedTransaction.product, amountSpent: self.selectedTransaction.amountSpent, taskParticipants: self.selectedUsers, taskDate: self.taskDate, userUID: user.userUID)
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        var taskParticipants = [[String: Any]]()
        for user in newEntry.taskParticipants {
            taskParticipants.append(["username": user.username, "userUID": user.userUID, "userProfileURL": user.userProfileURL.absoluteString])
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        let formattedDate = dateFormatter.string(from: newEntry.taskDate)
        self.titleText = "Hey, @\(user.username) \(titleText)!"
        self.bodyText = "\(newEntry.product) on \(formattedDate)"
        self.partnerToken = userWrapper.partner!.token
        sendPushNotification(to: partnerToken, title: titleText, body: bodyText)
        self.dismiss()
    }
    
    func sendPushNotification(to token: String, title: String, body: String) {
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAtmf3cpE:APA91bGYuNqm0U9i_TM6UNuze11Vwk813RNQs8LZvGYKMl9QcYgSxGy-EUeccJs1_3GSRiJKwq39xNH0Ji3CN2nQ7WiPgrdnhMIBIs6M2GBaCnJl2gEmsOdyCnlco4bU9GwK4OBF6obA", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        let data: [String: Any] = [
            "to": token,
            "notification": [
                "title": (title),
                "body": body
            ],
            "priority": "high"
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: data, options: [])
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error sending push notification: \(error)")
            } else if let response = response as? HTTPURLResponse {
                print("Push notification sent with response: \(response)")
            }
        }.resume()
    }
}
