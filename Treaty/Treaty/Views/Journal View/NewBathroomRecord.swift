//
//  NewBathroomRecord.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/7/23.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import Firebase

struct NewBathroomRecord: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var userWrapper: UserWrapper
    @EnvironmentObject var entryModel: EntryViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: Task Values
    @State var selectedType: String = ""
    @State var selectedSize: String = ""
    @State var product: String = ""
    @State var selectedProductIcon: String = ""
    @State var taskDate: Date = Date()
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
    
    struct BathroomRecordType: Identifiable{
        var id: UUID = .init()
        var product: String
        var productIcon: String
        var size: String
        var isSelected = false
    }
    
    var types: [BathroomRecordType] = [
        BathroomRecordType(product: "Pee", productIcon: "💦", size: "Small"),
        BathroomRecordType(product: "Pee", productIcon: "💦", size: "Normal"),
        BathroomRecordType(product: "Pee", productIcon: "💦", size: "Large"),
        BathroomRecordType(product: "Poop", productIcon: "💩", size: "Small"),
        BathroomRecordType(product: "Poop", productIcon: "💩", size: "Normal"),
        BathroomRecordType(product: "Poop", productIcon: "💩", size: "Large"),
        BathroomRecordType(product: "Throw Up", productIcon: "🤢", size: "Bile"),
        BathroomRecordType(product: "Throw Up", productIcon: "🤢", size: "Food"),
        BathroomRecordType(product: "Throw Up", productIcon: "🤢", size: "Materials")

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
                                    self.selectedSize = self.types[index].size
                                    self.selectedProductIcon = self.types[index].productIcon
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
                    Text("Bathroom Event")
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                }
                
                Section {
                    DatePicker("", selection: $taskDate)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                } header: {
                    Text("When Did It Happen?")
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Add New Event")
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
                        entryModel.filterTodayEntries(userUID: user.userUID)
                    }
                    .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                    .disabled(self.selectedType == "")
                }
            }
        }
    }
    
    func save(){
        let newEntry = BathroomRecord(id: UUID().uuidString, product: self.selectedType, productIcon: self.selectedProductIcon, taskDate: self.taskDate, userUID: user.userUID, size: self.selectedSize)
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("notes").addDocument(data: [
            "id": newEntry.id,
            "product": newEntry.product,
            "productIcon": newEntry.productIcon,
            "size": newEntry.size,
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
    func EntryButtonView(_ entry: BathroomRecordType)->some View{
        HStack(spacing: 12){
            Image(entry.productIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15)
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.product)
                    .font(.custom(ubuntu, size: 15, relativeTo: .body))
                    .foregroundColor(colorScheme == .light ? Color.black : Color.black)
                Text(entry.size)
                    .font(.custom(ubuntu, size: 15, relativeTo: .body))
                    .foregroundColor(colorScheme == .light ? Color.black : Color.black)
            }
        }
        .padding(8)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 5, y: 5)
    }
}
