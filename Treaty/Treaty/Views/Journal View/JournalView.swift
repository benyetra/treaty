//
//  JournalView.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/2/23.
//

import SwiftUI

struct JournalView: View {
    var basedOnUID: Bool = false
    var uid: String = ""
    @StateObject var entryModel: EntryViewModel = EntryViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Namespace var animation
    @ObservedObject var userWrapper: UserWrapper
    
    /// - Animation Properties
    @State var currentDate: Date = Date()
    @State private var currentWeek: [Date] = []
    @State private var selectedDate: Date = Date()
    @State private var expandMenu: Bool = false
    @State private var dimContent: Bool = false
    @State private var isShowingDatePicker: Bool = false
    var user: User
    @AppStorage("user_UID") var userUID: String = ""
    
    
    init(userWrapper: UserWrapper) {
        self.userWrapper = userWrapper
        self.user = userWrapper.user
    }
    
    var body: some View {
        CustomRefreshView(lottieFileName: "Loading", backgroundColor: Color(.clear), content:  {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 20){
                    
                    // Custom Date Picker....
                    CustomDatePicker(userWrapper: userWrapper)
                }
                .padding(.vertical)
            }
            // Safe Area View...
            .safeAreaInset(edge: .bottom) {
                
                HStack{
                    Button {
                        entryModel.addNewTask.toggle()
                    } label: {
                        Text("Add New Task")
                            .fontWeight(.bold)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(Color("Blue"),in: Capsule())
                    }
                    .sheet(isPresented: $entryModel.addNewTask) {
                    } content: {
                        NewEntry(userWrapper: userWrapper)
                            .environmentObject(entryModel)
                            .onAppear {
                                MainView().fetchUserData()
                            }
                    }
                    Button {
                        entryModel.addNewBathroomRecord.toggle()
                    } label: {
                        Text("Bathroom Break")
                            .fontWeight(.bold)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(Color("Sand"),in: Capsule())
                    }
                    .sheet(isPresented: $entryModel.addNewBathroomRecord) {
                    } content: {
                        NewBathroomRecord(userWrapper: userWrapper)
                            .environmentObject(entryModel)
                            .onAppear {
                                MainView().fetchUserData()
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.top,10)
                .foregroundColor(.white)
                .background(.ultraThinMaterial)
            }
        }, onRefresh: {
            entryModel.filterTodayEntries(userUID: user.userUID)
        })
    }
}
