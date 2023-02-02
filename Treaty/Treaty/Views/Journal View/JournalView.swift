//
//  JournalView.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/19/23.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import Firebase

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
        
        ScrollView(.vertical, showsIndicators: false) {
            // MARK: Lazy Stack With Pinned Header
            LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                
                Section {
                    
                    // MARK: Current Week View
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack(spacing: 10){
                            
                            ForEach(entryModel.currentWeek,id: \.self){day in
                                
                                VStack(spacing: 10){
                                    
                                    Text(entryModel.extractDate(date: day, format: "dd"))
                                        .font(.system(size: 15))
                                        .fontWeight(.semibold)
                                    
                                    // EEE will return day as MON,TUE,....etc
                                    Text(entryModel.extractDate(date: day, format: "EEE"))
                                        .font(.system(size: 14))
                                    
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 8, height: 8)
                                        .opacity(entryModel.isToday(date: day) ? 1 : 0)
                                }
                                // MARK: Foreground Style
                                .foregroundStyle(entryModel.isToday(date: day) ? (colorScheme == .light ? Color.white : Color.black) : (colorScheme == .light ? Color.black : Color.white))
                                .foregroundColor(entryModel.isToday(date: day) ? (colorScheme == .light ? Color.black : Color.white) : (colorScheme == .light ? Color.white : Color.black))
                                // MARK: Capsule Shape
                                .frame(width: 45, height: 90)
                                .background(
                                    
                                    ZStack{
                                        // MARK: Matched Geometry Effect
                                        if entryModel.isToday(date: day){
                                            Capsule()
                                                .fill(Color("Blue"))
                                                .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                                        }
                                    }
                                )
                                .contentShape(Capsule())
                                .onTapGesture {
                                    // Updating Current Day
                                    withAnimation{
                                        entryModel.currentDay = day
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    EntriesView()

                } header: {
                    HeaderView()
                }
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .overlay(
            Button(action: {
                entryModel.addNewTask.toggle()
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("Blue"),in: Circle())
            })
            .padding()
            
            ,alignment: .bottomTrailing
        )
        .sheet(isPresented: $entryModel.addNewTask) {
        } content: {
            NewEntry(userWrapper: userWrapper)
                .environmentObject(entryModel)
                .onAppear {
                    MainView().fetchUserData()
                }
        }
    }
    
    
    // MARK: Tasks View
    func EntriesView()->some View{
        LazyVStack(spacing: 20){
            if let entries = entryModel.filteredEntries{
                if entries.isEmpty{
                    Text("No tasks found!")
                        .font(.system(size: 16))
                        .fontWeight(.light)
                        .offset(y: 100)
                }
                else{
                    ForEach(entries){entry in
                        EntryCardView(entry: entry)
                    }
                }
            }
            else{
                // MARK: Progress View
                ProgressView()
                    .offset(y: 100)
            }
        }
        .padding()
        .padding(.top)
        // MARK: Updating Tasks
        .onChange(of: entryModel.currentDay) { newValue in
            entryModel.filterTodayEntries(userUID: user.userUID)
        }
    }
    
    // MARK: Task Card View
    func EntryCardView(entry: Entry)->some View{
        HStack(alignment: .top,spacing: 30){
            VStack(spacing: 10){
                Circle()
                    .fill(entryModel.isCurrentHour(date: entry.taskDate) ? (colorScheme == .light ? Color.black : Color.white) : .clear)
                    .frame(width: 15, height: 15)
                    .background(
                    
                        Circle()
                            .stroke((colorScheme == .light ? Color("Blue") : Color("Sand")), lineWidth: 1)
                            .padding(-3)
                    )
                    .scaleEffect(!entryModel.isCurrentHour(date: entry.taskDate) ? 0.8 : 1)
                
                Rectangle()
                    .fill(colorScheme == .light ? Color("Blue") : Color("Sand"))
                    .frame(width: 3)
            }
            VStack{
                
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(entry.product)
                                .font(.title2.bold())
                                .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Blue"))
                            Text("\(entry.amountSpent)")
                                .font(.title3.bold())
                                .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Blue"))
                                .hAlign(.trailingLastTextBaseline)
                            Image("treat")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }
                    }
                    .hLeading()
                }

                // MARK: Team Members
                HStack(spacing: 0){
                    HStack(spacing: -10){
                        HStack {
                            ForEach(0..<entry.taskParticipants.count, id: \.self) { i in
                                WebImage(url: entry.taskParticipants[i].userProfileURL)
                                    .placeholder(Image("NullProfile"))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 45, height: 45)
                                    .clipShape(Circle())
                                    .background(
                                        Circle()
                                            .stroke((colorScheme == .light ? Color("Sand") : Color("Blue")), lineWidth: 5)
                                    )
                            }
                        }
                    }
                    .hLeading()
                    Text(entry.taskDate.formatted(date: .omitted, time: .shortened))
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Blue"))
                        .padding(.horizontal, 10)
                    // MARK: Delete Button
                    Button {
                        deleteEntry(entry: entry)
                        entryModel.filterTodayEntries(userUID: user.userUID)
                        print("deleting post \(entry)")
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(colorScheme == .light ? Color.black : Color.white)
                            .padding(10)
                            .background((colorScheme == .light ? Color.white : Color.black), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.top)
            }
            .foregroundColor(entryModel.isCurrentHour(date: entry.taskDate) ? .black : .black)
            .padding(entryModel.isCurrentHour(date: entry.taskDate) ? 15 : 15)
            .padding(.bottom,entryModel.isCurrentHour(date: entry.taskDate) ? 10 : 10)
            .hLeading()
            .background(
                Color("Sand")
                    .cornerRadius(25)
                    .opacity(entryModel.isCurrentHour(date: entry.taskDate) ? 1 : 1)
            )
        }
        .hLeading()
    }

    func deleteEntry(entry: Entry) {
        Task {
            do {
                /// Step 2: Delete Firestore Document
                guard let entryID =  entry.id else {return}
                try await Firestore.firestore().collection("entries").document(entryID).delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    let ubuntu = "Ubuntu"
    func HeaderView()->some View{
        return HStack(spacing: 10){
            VStack(alignment: .leading, spacing: 10) {
                Text("Selected Date: \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                    .foregroundColor(.gray)
                Text("Journal Entries")
                    .font(.largeTitle.bold())
            }
            .hLeading()
            Button(action: {
                self.isShowingDatePicker = true
            }) {
                Image(systemName: "calendar.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
            }.sheet(isPresented: $isShowingDatePicker) {
                VStack {
                    Text("Select A Date")
                        .font(.custom(ubuntu, size: 20, relativeTo: .callout))
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                        .padding(.top, 5)
                        .vAlign(.topLeading)
                    CustomDatePicker(currentDate: $selectedDate)
                    Button(action: {
                        withAnimation {
                            self.entryModel.currentWeek = self.entryModel.generateWeek(for: self.selectedDate)
                            self.entryModel.currentDay = self.selectedDate
                        }
                        self.isShowingDatePicker = false
                    }) {
                        Text("Done")
                            .font(.custom(ubuntu, size: 20, relativeTo: .headline))
                            .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                            .fillView(colorScheme == .light ? Color("Sand") : Color("Blue"))
                            .hAlign(.center)
                    }
                    .vAlign(.bottom)
                }.hAlign(.center)
            }
        }
        .padding()
        .padding(.top,getSafeArea().top)
        .background(colorScheme == .light ? Color.white : Color.black)
    }


    
    func extractDate(date: Date, format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateString = dateFormatter.string(from: date)
        if let extractedDate = dateFormatter.date(from: dateString) {
            return extractedDate
        }
        return date
    }
    
    func updateCurrentWeek() {
        withAnimation {
            let today = Date()
            let calendar = Calendar.current
            
            let week = calendar.dateInterval(of: .weekOfMonth, for: today)
            
            guard let firstWeekDay = week?.start else {
                return
            }
            
            currentWeek = (0..<7).compactMap { day in
                return calendar.date(byAdding: .day, value: day, to: firstWeekDay)
            }
        }
    }
    
    func updateCurrentDay(selectedDate: Date) {
        withAnimation {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            let selectedDateString = dateFormatter.string(from: selectedDate)

            if let currentDay = dateFormatter.date(from: selectedDateString) {
                entryModel.currentDay = currentDay
            }
        }
    }
}

// MARK: UI Design Helper functions
extension View{
    func hLeading()->some View{
        self
            .frame(maxWidth: .infinity,alignment: .leading)
    }
    func hTrailing()->some View{
        self
            .frame(maxWidth: .infinity,alignment: .trailing)
    }
    func hCenter()->some View{
        self
            .frame(maxWidth: .infinity,alignment: .center)
    }
    // MARK: Safe Area
    func getSafeArea()->UIEdgeInsets{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .zero
        }
        guard let safeArea = screen.windows.first?.safeAreaInsets else{
            return .zero
        }
        return safeArea
    }
}
