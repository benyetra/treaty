//
//  NewEntry.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/22/23.
//
import SwiftUI
import SDWebImageSwiftUI

struct NewEntry: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var userWrapper: UserWrapper
    @EnvironmentObject var entryModel: EntryViewModel
    @Environment(\.colorScheme) private var colorScheme

    // MARK: Task Values
    @State var taskTitle: String = ""
    @State var taskDescription: String = ""
    @State var taskDate: Date = Date()
    @State private var selectedUser: Int? = nil
    @State private var isButton1Selected = false
    @State private var isButton2Selected = false
    @State private var selectedButton = -1
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
                                Button(action: { print("Button with tag: ", index, " pressed") }) {
                                    EntryButtonView(types[index])
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                }.tag(index)
                                    .buttonStyle(BorderlessButtonStyle())
                                    .hAlign(.leading)
                            }
                        }
                    }
                } header: {
                    Text("Completed Task")
                }
                
                Section {
                    HStack {
                        Button(action: {
                            self.isButton1Selected.toggle()
                            print("button 1 pressed")
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
                    HStack {
                        Button(action: {
                            self.isButton2Selected.toggle()
                            print("button 2 pressed")
                        }) {
                            Image("NullProfile")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                                .opacity(isButton2Selected ? 1 : 0.5)
                        }
                        Text("User 2")
                        
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
            // MARK: Disbaling Dismiss on Swipe
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
                        saveEntry()
                        //                        if let task = entryModel.editTask{
                        //
                        //                            task.taskTitle = taskTitle
                        //                            task.taskDescription = taskDescription
                        //                        }
                        //                        else{
                        //                            let task = Entry()
                        //                            task.taskTitle = taskTitle
                        //                            task.taskDescription = taskDescription
                        //                            task.taskDate = taskDate
                    }
                    // Dismissing View
                    //                        dismiss()
                }
                //                    .disabled(taskTitle == "" || taskDescription == "")
            }
        }
    }
    func saveEntry() {
        print("saved")
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
                    .foregroundColor(colorScheme == .light ? Color.white : Color.black)
            }
            HStack {
                Text("\(entry.amountSpent)")
                    .font(.custom(ubuntu, size: 15, relativeTo: .title3))
                    .fontWeight(.medium)
                    .foregroundColor(Color("Blue"))
                Image("treat")
                    .resizable()
                    .frame(width: 11, height: 11)
            }
        }
        .padding(8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 5, y: 5)
    }
}
