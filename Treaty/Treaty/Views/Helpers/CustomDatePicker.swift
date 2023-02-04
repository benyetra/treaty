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
                            HStack {
                                Text(entry.taskDate, style: .time)
                                
                                Text(entry.product)
                                    .font(.title2.bold())
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
                                }.hAlign(.trailing)
                                
//                                VStack(alignment: .leading, spacing: 10) {
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity,alignment: .leading)
                                .background(
                                    
                                    Color("Sand")
                                        .opacity(0.5)
                                        .cornerRadius(10)
                                )
                            }
                        }
                }else{
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
                }
                else{
                    
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

struct CustomDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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
