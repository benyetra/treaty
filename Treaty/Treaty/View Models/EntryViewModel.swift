//
//  JournalViewModel.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/22/23.
//

import SwiftUI
import FirebaseFirestore

class EntryViewModel: ObservableObject{
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("partnerUsernameStored") var partnerUsernameStored: String = ""
    @AppStorage("partnerTokenStored") var tokenStored: String = ""
    @AppStorage("user_name") var usernameStored: String = ""
    
    @Published var selectedDay: Date = Date()
    
    // Sample Tasks
    @Published var storedEntries: [Entry] = []
    
    // MARK: Current Week Days
    @Published var currentWeek: [Date] = []
    
    // MARK: Current Day
    @Published var currentDay: Date = Date()
    
    // MARK: Filtering Today Tasks
    @Published var filteredEntries: [Entry]?
    
    // MARK: New Task View
    @Published var addNewTask: Bool = false
    
    // MARK: Intializing
    init(){
        fetchCurrentWeek()
        filterTodayEntries(userUID: userUID)
    }
    
    // MARK: Filter Today Tasks
    func filterTodayEntries(userUID: String) {
        fetchEntries { (entries) in
            // use the entries here
            for entry in entries {
                self.storedEntries = entries
            }
            DispatchQueue.global(qos: .userInteractive).async {
                
                let calendar = Calendar.current
                
                let filtered = self.storedEntries.filter{
                    return ($0.userUID == userUID || $0.taskParticipants.contains(where: { $0.username == self.usernameStored}) || $0.taskParticipants.contains(where: { $0.username == self.partnerUsernameStored}))
                }.sorted { task1, task2 in
                    return task2.taskDate < task1.taskDate
                }
                DispatchQueue.main.async {
                    withAnimation{
                        self.filteredEntries = filtered
                    }
                }
            }
        }
    }


    func fetchCurrentWeek() {
        let today = Date()
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: today)

        guard let firstWeekDay = week?.start else {
            return
        }

        currentWeek.removeAll()
        (0..<7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
                currentWeek.append(weekday)
            }
        }
    }

    func fetchEntries(completion: @escaping ([Entry]) -> Void) {
        var entries: [Entry] = []
        let db = Firestore.firestore()
        db.collection("entries").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let product = data["product"] as! String
                    let amountSpent = data["amountSpent"] as! Int
                    let taskDate = data["taskDate"] as! Timestamp
                    let userUID = data["userUID"] as! String
                    if let taskParticipants = data["taskParticipants"] as? [[String: Any]] {
                        self.getTaskParticipants(taskParticipants: taskParticipants) { (users) in
                            let entry = Entry(id: document.documentID, product: product, amountSpent: amountSpent, taskParticipants: users, taskDate:taskDate.dateValue(), userUID: userUID)
                            entries.append(entry)
                            if entries.count == querySnapshot!.count {
                                completion(entries)
                            }
                        }
                    } else {
                        print("No taskparticipants present or is nil")
                        let entry = Entry(id: document.documentID, product: product, amountSpent: amountSpent, taskParticipants: [], taskDate: taskDate.dateValue(), userUID: userUID)
                        entries.append(entry)
                        if entries.count == querySnapshot!.count {
                            completion(entries)
                        }
                    }
                }
            }
        }
    }
    
    func getTaskParticipants(taskParticipants: [[String:Any]], completion: @escaping ([User]) -> Void) {
        var users: [User] = []
        let db = Firestore.firestore()
        var count = 0
        for participant in taskParticipants {
            if let username = participant["username"] as? String {
                db.collection("Users").whereField("username", isEqualTo: username).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting document: (error)")
                    } else {
                        if let documents = querySnapshot?.documents {
                            for document in documents {
                                let data = document.data()
                                if let user = try? Firestore.Decoder().decode(User.self, from: data) {
                                    users.append(user)
                                }
                            }
                        } else {
                            print("No such document")
                        }
                    }
                    count += 1
                    if count == taskParticipants.count {
                        completion(users)
                    }
                }
            }
        }
    }
    
    // MARK: Extracting Date
    func extractDate(date: Date,format: String)->String{
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    // MARK: Checking if current Date is Today
    func isToday(date: Date)->Bool{
        
        let calendar = Calendar.current
        
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    // MARK: Checking if the currentHour is task Hour
    func isCurrentHour(date: Date)->Bool{
        
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let currentHour = calendar.component(.hour, from: Date())
        
        return hour == currentHour
    }
    
    func generateWeek(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: date)

        guard let firstWeekDay = week?.start else {
            return []
        }

        var weekDays: [Date] = []
        (0..<7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
                weekDays.append(weekday)
            }
        }

        return weekDays
    }
}

