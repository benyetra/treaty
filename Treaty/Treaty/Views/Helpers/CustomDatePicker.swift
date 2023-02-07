//
//  CustomDatePicker.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/1/23.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import Firebase

struct CustomDatePicker: View {
    @Binding var currentDate: Date
    @StateObject var entryModel: EntryViewModel = EntryViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedDate: Date = Date()
    @State var currentMonth: Int = 0
    @ObservedObject var userWrapper: UserWrapper
    @AppStorage("user_UID") var userUID: String = ""
    
    var user: User
     
     init(userWrapper: UserWrapper) {
         self.userWrapper = userWrapper
         self.user = userWrapper.user
         self._currentDate = Binding.constant(Date())
         self._selectedDate = State(initialValue: Date())
         self._currentMonth = State(initialValue: 0)
     }
    
    var body: some View {
        
        VStack(spacing: 35){
            
            // Days...
            let days: [String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
            
            HStack(spacing: 20){
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(extraDate()[1])
                        .font(.title.bold())
                }
                
                Spacer(minLength: 0)
                
                Button {
                    withAnimation{
                        currentMonth -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }

                Button {
                    
                    withAnimation{
                        currentMonth += 1
                    }
                    
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            // Day View...
            
            HStack(spacing: 0){
                ForEach(days,id: \.self){day in
                    
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Dates....
            // Lazy Grid..
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns,spacing: 15) {
                
                ForEach(extractDate()){value in
                    
                    CardView(value: value)
                        .background(
                        
                            Capsule()
                                .fill(Color("Blue"))
                                .padding(.horizontal,8)
                                .opacity(isSameDay(date1: value.date, selectedDate: selectedDate) ? 1 : 0)
                        )
                        .onTapGesture {
                            selectedDate = value.date
                            currentDate = value.date
                            entryModel.filterTodayEntries(userUID: userUID)
                        }
                }
            }
            
            VStack(spacing: 15){
                
                Text("Tasks")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.vertical,20)
                
                if let filteredEntries = entryModel.filteredEntries, !filteredEntries.isEmpty {
                    ForEach(filteredEntries){entry in
                        if isSameDay(date1: entry.taskDate, selectedDate: selectedDate) {
                            EntryCardView(entry: entry)
                        }
                    }
                }

                if let filteredRecords = entryModel.filteredBathroomRecords, !filteredRecords.isEmpty {
                    ForEach(filteredRecords) { record in
                        if isSameDay(date1: record.taskDate, selectedDate: selectedDate) {
                            RecordCardView(record: record)
                        }
                    }
                }

                if entryModel.filteredEntries == nil && entryModel.filteredBathroomRecords == nil {
                    Text("No Task Found")
                }
            }
            .padding()
        }
        .onChange(of: currentMonth) { newValue in
            
            // updating Month...
            currentDate = getCurrentMonth()
        }
    }
    
    @ViewBuilder
    func CardView(value: DateValue)->some View{
        
        VStack{
            
            if value.day != -1{
                
                if let note = entryModel.filteredEntries?.first(where: { note in
                    
                    return isSameDay(date1: note.taskDate, selectedDate: value.date)
                }){
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: note.taskDate, selectedDate: selectedDate) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    Circle()
                        .fill(isSameDay(date1: note.taskDate, selectedDate: selectedDate) ? .white : Color("Sand"))
                        .frame(width: 8,height: 8)
                } else if let record = entryModel.filteredBathroomRecords?.first(where: { record in
                    return isSameDay(date1: record.taskDate, selectedDate: value.date)
                }) {
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: record.taskDate, selectedDate: selectedDate) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    Circle()
                        .fill(isSameDay(date1: record.taskDate, selectedDate: selectedDate) ? .white : Color("Sand"))
                        .frame(width: 8,height: 8)
                }else{
                    
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: value.date, selectedDate: selectedDate) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical,9)
        .frame(height: 60,alignment: .top)
    }
    
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
                            if entry.amountSpent != 0 {
                                Text("\(entry.amountSpent)")
                                    .font(.title3.bold())
                                    .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Blue"))
                                    .hAlign(.trailingLastTextBaseline)
                                Image("treat")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                            }
                        }
                    }
                    .hLeading()
                }

                // MARK: Team Members
                HStack(spacing: 0){
                    HStack(spacing: -10){
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
                    .hLeading()
                    Text(entry.taskDate.formatted(date: .omitted, time: .shortened))
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Blue"))
                        .padding(.horizontal, 10)
                    // MARK: Delete Button
                    Button {
                        deleteEntry(entry: entry)
                        if entry.taskParticipants.count == 1 {
                            if entry.taskParticipants.first == userWrapper.user {
                                user.removeCredits(amount: entry.amountSpent)
                            } else {
                                userWrapper.partner?.removeCredits(amount: entry.amountSpent)
                            }
                        } else if entry.taskParticipants.count == 2 {
                            user.removeCredits(amount: entry.amountSpent)
                            userWrapper.partner?.removeCredits(amount: entry.amountSpent)
                        }
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
    
    func RecordCardView(record: BathroomRecord)->some View{
        HStack(alignment: .top,spacing: 30){
            VStack(spacing: 10){
                Circle()
                    .fill(entryModel.isCurrentHour(date: record.taskDate) ? (colorScheme == .light ? Color.black : Color.white) : .clear)
                    .frame(width: 15, height: 15)
                    .background(
                    
                        Circle()
                            .stroke((colorScheme == .light ? Color("Sand") : Color("Blue")), lineWidth: 1)
                            .padding(-3)
                    )
                    .scaleEffect(!entryModel.isCurrentHour(date: record.taskDate) ? 0.8 : 1)
                
                Rectangle()
                    .fill(colorScheme == .light ? Color("Sand") : Color("Blue"))
                    .frame(width: 3)
            }
            VStack{
                
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(record.product)
                                .font(.title2.bold())
                                .foregroundColor(colorScheme == .light ? Color("Sand") : Color("Sand"))
                            Text("\(record.size)")
                                .font(.title3.bold())
                                .foregroundColor(colorScheme == .light ? Color("Sand") : Color("Sand"))
                                .hAlign(.trailingLastTextBaseline)
                        }
                    }
                    .hLeading()
                }

                HStack(){
                    HStack {
                        let emojiString = "\(record.productIcon)"
                        let emojiImage = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
                            emojiString.draw(at: CGPoint.zero, withAttributes: [.font: UIFont.systemFont(ofSize: 30)])
                        }
                        Image(uiImage: emojiImage)
                            .resizable()
                            .frame(width: 30, height: 30)
                    }.hAlign(.leadingFirstTextBaseline)
                    Text(record.taskDate.formatted(date: .omitted, time: .shortened))
                        .foregroundColor(colorScheme == .light ? Color("Sand") : Color("Sand"))
                        .padding(.horizontal, 10)
                    // MARK: Delete Button
                    Button {
                        deleteRecord(record: record)
                        entryModel.filterTodayEntries(userUID: user.userUID)
                        print("deleting post \(record)")
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(colorScheme == .light ? Color.black : Color.white)
                            .padding(10)
                            .background((colorScheme == .light ? Color.white : Color.black), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.top)
            }
            .foregroundColor(entryModel.isCurrentHour(date: record.taskDate) ? .black : .black)
            .padding(entryModel.isCurrentHour(date: record.taskDate) ? 15 : 15)
            .padding(.bottom,entryModel.isCurrentHour(date: record.taskDate) ? 10 : 10)
            .hLeading()
            .background(
                Color("Blue")
                    .cornerRadius(25)
                    .opacity(entryModel.isCurrentHour(date: record.taskDate) ? 1 : 1)
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
    
    func deleteRecord(record: BathroomRecord) {
        Task {
            do {
                /// Step 2: Delete Firestore Document
                guard let entryID =  record.id else {return}
                try await Firestore.firestore().collection("notes").document(entryID).delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func isSameDay(date1: Date, selectedDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: selectedDate)
    }

    
    // extrating Year And Month for display...
    func extraDate()->[String]{
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: currentDate) - 1
        let year = calendar.component(.year, from: currentDate)
        
        return ["\(year)",calendar.monthSymbols[month]]
    }
    
    func getCurrentMonth()->Date{
        
        let calendar = Calendar.current
        
        // Getting Current Month Date....
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else{
            return Date()
        }
                
        return currentMonth
    }
    
    func extractDate()->[DateValue]{
        
        let calendar = Calendar.current
        
        // Getting Current Month Date....
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            
            // getting day...
            let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
        
        // adding offset days to get exact week day...
        let firstWeekday = calendar.component(.weekday, from: days.first!.date)
        
        for _ in 0..<firstWeekday - 1{
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
}


// Extending Date to get Current Month Dates...
extension Date{
    
    func getAllDates()->[Date]{
        
        let calendar = Calendar.current
        
        // getting start Date...
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
        
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        // getting date...
        return range.compactMap { day -> Date in
            
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
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
