//
//  NewEntry.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/22/23.
//
import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import Firebase

struct NewEntry: View {
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
    
    var user: User
    
    init(userWrapper: UserWrapper) {
        self.userWrapper = userWrapper
        self.user = userWrapper.user
    }
    
    struct EntryType: Identifiable{
        var id: UUID = .init()
        var amountSpent: Int
        var product: String
        var productIcon: String
        var isSelected = false
    }
    
    var types: [EntryType] = [
        EntryType(amountSpent: 10, product: "Walk", productIcon: "walk"),
        EntryType(amountSpent: 3, product: "Gave Medicine", productIcon: "pills"),
        EntryType(amountSpent: 25, product: "Went to Vet", productIcon: "vet"),
        EntryType(amountSpent: 5, product: "Wake Up with Dog", productIcon: "wakeup"),
        EntryType(amountSpent: 15, product: "Went to Park", productIcon: "park"),
        EntryType(amountSpent: 5, product: "Played with Dog", productIcon: "play"),
        EntryType(amountSpent: 10, product: "Brushed Hair", productIcon: "comb"),
        EntryType(amountSpent: 10, product: "Brushed Teeth", productIcon: "brushedteeth"),
        EntryType(amountSpent: 20, product: "Bath", productIcon: "bath"),
        EntryType(amountSpent: 2, product: "Feed Dog", productIcon: "food"),
        EntryType(amountSpent: 2, product: "Fill Water", productIcon: "water"),
        EntryType(amountSpent: 12, product: "Late Night Wake Ups", productIcon: "night")
    ]
    
    
    var body: some View {
        NavigationView{
            List{
                Section {
                    HStack {
                        VStack(spacing: 12){
                            ForEach(types.indices, id: \.self) { index in
                                Button(action: {
                                    self.selectedIndex = index
                                    self.selectedType = self.types[index].product
                                    self.selectedAmount = self.types[index].amountSpent
                                    print("Button with tag: \(self.types[index].product) pressed")
                                }) {
                                    EntryButtonView(types[index])
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                        .background(index == self.selectedIndex ? Color("Blue") : Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .tag(index)
                                .buttonStyle(BorderlessButtonStyle())
                                .hAlign(.leading)
                            }
                        }
                    }
                } header: {
                    Text("Completed Task")
                }
                
                Section {
                    Group {
                        HStack {
                            Button(action: {
                                self.isButton1Selected.toggle()
                                if self.isButton1Selected {
                                    self.selectedUsers.append(self.userWrapper.user)
                                } else {
                                    self.selectedUsers.removeAll(where: { $0.username == self.userWrapper.user.username })
                                }
                            }) {
                                WebImage(url: user.userProfileURL).placeholder{
                                    Image("NullProfile")
                                        .resizable()
                                }
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                                .opacity(isButton1Selected ? 1 : 0.5)
                            }
                            Text(user.username)
                        }
                        if userWrapper.partner != nil {
                            HStack {
                                Button(action: {
                                    if let partner = self.userWrapper.partner {
                                        self.isButton2Selected.toggle()
                                        if self.isButton2Selected {
                                            self.selectedUsers.append(User(id: "", username: partner.username, userUID: "", userEmail: "", userProfileURL: partner.userProfileURL, token: partner.token, credits: partner.credits))
                                        } else {
                                            self.selectedUsers.removeAll(where: { $0.username == partner.username })
                                        }
                                    }
                                }) {
                                    if let userProfileURL = userWrapper.partner?.userProfileURL {
                                        WebImage(url: userProfileURL).placeholder {
                                            Image("NullProfile")
                                                .resizable()
                                        }
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                                        .opacity(isButton2Selected ? 1 : 0.5)
                                    }
                                }
                                if let username = userWrapper.partner?.username {
                                    Text(username)
                                } else {
                                    Text("Your Partner")
                                }
                            }
                        } else {
                            Text("No partner currently linked. If you have a partner add them on the Profile screen.")
                        }
                    }
                } header: {
                    Text("Participants")
                }

                
                Section {
                    DatePicker("", selection: $taskDate)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                } header: {
                    Text("Task Date")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Add New Task")
            .navigationBarTitleDisplayMode(.inline)
            // MARK: Disabling Dismiss on Swipe
            .interactiveDismissDisabled()
            // MARK: Action Buttons
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel"){
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save"){
                        save()
                        if selectedUsers.count == 1 {
                            if selectedUsers.first == userWrapper.user {
                                user.addCredits(amount: selectedAmount)
                            } else {
                                userWrapper.partner?.addCredits(amount: selectedAmount)
                            }
                        } else if selectedUsers.count == 2 {
                            user.addCredits(amount: selectedAmount)
                            userWrapper.partner?.addCredits(amount: selectedAmount)
                        }
                        entryModel.filterTodayEntries(userUID: user.userUID)
                        print("Array count: \(self.selectedUsers.count)")
                    }
                    .disabled(self.selectedUsers.isEmpty || self.selectedType == "")
                }
            }
        }
    }
    
    func save(){
        let newEntry = Entry(id: UUID().uuidString, product: self.selectedType, amountSpent: self.selectedAmount, taskParticipants: self.selectedUsers, taskDate: self.taskDate, userUID: user.userUID)
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



    /// - Transaction Card View
    @ViewBuilder
    func EntryButtonView(_ entry: EntryType)->some View{
        HStack(spacing: 12){
            Image(entry.productIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15)
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.product)
                    .font(.custom(ubuntu, size: 15, relativeTo: .body))
                    .foregroundColor(colorScheme == .light ? Color.black : Color.black)
            }
            HStack {
                Image("treat")
                    .resizable()
                    .frame(width: 11, height: 11)
                Text("\(entry.amountSpent)")
                    .font(.custom(ubuntu, size: 15, relativeTo: .title3))
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .light ? Color.black : Color.black)
            }
        }
        .padding(8)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 5, y: 5)
    }
}
