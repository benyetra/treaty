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
                            self.selectedUser = 0
                        }) {
                            WebImage(url: user.userProfileURL).placeholder{
                                // MARK: Placeholder Imgae
                                Image("NullProfile")
                                    .resizable()
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        }
                        .foregroundColor(self.selectedUser == 0 ? .blue : .gray)
                        
                        Button(action: {
                            self.selectedUser = 1
                        }) {
                            Image("NullProfile")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        }
                        .foregroundColor(self.selectedUser == 1 ? .blue : .gray)
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
