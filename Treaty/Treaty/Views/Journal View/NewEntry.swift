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

    // MARK: Task Values
    @State var taskTitle: String = ""
    @State var taskDescription: String = ""
    @State var taskDate: Date = Date()
    @State private var selectedUser: Int? = nil
    @State private var isButton1Selected = false
    @State private var isButton2Selected = false
    var user: User

    init(userWrapper: UserWrapper) {
        self.userWrapper = userWrapper
        self.user = userWrapper.user
    }
    
    @EnvironmentObject var entryModel: EntryViewModel
    var body: some View {
        
        NavigationView{
            
            List{
                
                Section {
                    TextField("Go to work", text: $taskTitle)
                } header: {
                    Text("Task Title")
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
                    Text("Which Pawrent")
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
}
