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
    @State var selectedType: String = ""
    @State var product: String = ""
    @State var taskParticipants: String = ""
    @State var taskDate: Date = Date()
    @State private var selectedUsers: [User] = []
    @State private var isButton1Selected = false
    @State private var isButton2Selected = false
    @State private var selectedButton = -1
    @State var selectedIndex: Int? = nil
    @State private var partnerUser: User?
    @State private var partnerModel: PartnerModel?
    @State private var partnerUsername: String = ""
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
                                    self.selectedUsers.append(self.user)
                                } else {
                                    self.selectedUsers.removeAll(where: { $0.username == self.user.username })
                                }
                            }) {
                                WebImage(url: user.userProfileURL).placeholder{
                                    // MARK: Placeholder Imgae
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
                                    self.isButton2Selected.toggle()
                                    if let partner = self.userWrapper.partner {
                                        if self.isButton2Selected {
                                            let newUser = User(id: "", username: partner.username, userUID: "", userEmail: "", userProfileURL: partner.userProfileURL)
                                            self.selectedUsers.append(newUser)
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
                            Text("No partner linked.").opacity(0)
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
                        saveEntry(product: selectedType, taskDate: taskDate, taskParticipants: taskParticipants)
                        // Dismissing View
                        dismiss()
                    }
                }
            }
        }
    }
    
    func saveEntry(product: String, taskDate: Date, taskParticipants: String) {
        let entry = Entry(product: product, taskParticipants: taskParticipants, taskDate: taskDate)
        let db = Firestore.firestore()
        db.collection("Entries").addDocument(data: [
            "product": entry.product,
            "taskParticipants": entry.taskParticipants,
            "taskDate": entry.taskDate,
        ]) { (error) in
            if let error = error {
                print("Error adding document: (error)")
            } else {
                print("Document added with ID: (entry.id)")
            }
        }
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
                Text("\(entry.amountSpent)")
                    .font(.custom(ubuntu, size: 15, relativeTo: .title3))
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .light ? Color.black : Color.black)
                Image("treat")
                    .resizable()
                    .frame(width: 11, height: 11)
            }
        }
        .padding(8)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 5, y: 5)
    }
}
