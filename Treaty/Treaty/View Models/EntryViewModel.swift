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
    @AppStorage("partnerUID") var partnerUIDStored: String = ""
    @AppStorage("partnerTokenStored") var tokenStored: String = ""
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("filter") var filter: String = ""
    
    @Published var selectedDay: Date = Date()
    
    // Sample Tasks
    @Published var storedEntries: [Entry] = []
    
    // Bathroom Records
    @Published var storedBathroomRecords: [BathroomRecord] = []
    
    // MARK: Current Week Days
    @Published var currentWeek: [Date] = []
    
    // MARK: Current Day
    @Published var currentDay: Date = Date()
    
    // MARK: Filtering Today Tasks
    @Published var filteredEntries: [Entry]?
    
    // MARK: Filtering Today Tasks
    @Published var myFilteredEntries: [Entry]?
    
    // MARK: Filtering Today Tasks
    @Published var filteredBathroomRecords: [BathroomRecord]?
    
    // MARK: Filtering Today Tasks
    @Published var myFilteredBathroomRecords: [BathroomRecord]?

    // MARK: New Task View
    @Published var addNewTask: Bool = false
    
    //MARK: New Bathroom Record
    @Published var addNewBathroomRecord: Bool = false
    
    // MARK: Intializing
    init(){
        fetchCurrentWeek()
        filterTodayEntries(userUID: userUID, filter: filter)
    }
    
    func filterTodayEntries(userUID: String, filter: String) {
        fetchEntries { (entries) in
            self.storedEntries = entries
            DispatchQueue.global(qos: .userInteractive).async {
                var filteredEntries = self.storedEntries
                if filter == "currentUser" {
                    filteredEntries = filteredEntries.filter {
                        return $0.userUID == userUID
                    }
                } else if filter == "partnerUser" {
                    filteredEntries = filteredEntries.filter {
                        return $0.taskParticipants.contains(where: { $0.username == self.partnerUsernameStored })
                    }
                } else if filter == "both" {
                    filteredEntries = filteredEntries.filter {
                        return ($0.userUID == userUID || $0.taskParticipants.contains(where: { $0.username == self.partnerUsernameStored }))
                    }
                }
                filteredEntries.sort { $0.taskDate > $1.taskDate }
                self.fetchBathroomRecords {  (records) in
                    self.storedBathroomRecords = records
                    var filteredRecords = self.storedBathroomRecords
                    if filter == "currentUser" {
                        filteredRecords = filteredRecords.filter {
                            return $0.userUID == userUID
                        }
                    } else if filter == "partnerUser" {
                        filteredRecords = filteredRecords.filter {
                            return $0.userUID == self.partnerUIDStored
                        }
                    } else if filter == "both" {
                        filteredRecords = filteredRecords.filter {
                            return ($0.userUID == userUID || $0.userUID == self.partnerUIDStored)
                        }
                    }
                    filteredRecords.sort { $0.taskDate > $1.taskDate }
                    DispatchQueue.main.async {
                        withAnimation {
                            self.filteredEntries = filteredEntries
                            self.filteredBathroomRecords = filteredRecords
                        }
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
    
    func fetchBathroomRecords(completion: @escaping ([BathroomRecord]) -> Void) {
        var records: [BathroomRecord] = []
        let db = Firestore.firestore()
        db.collection("notes").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let product = data["product"] as! String
                    let productIcon = data["productIcon"] as! String
                    let taskDate = data["taskDate"] as! Timestamp
                    let userUID = data["userUID"] as! String
                    let size = data["size"] as! String
                    let record = BathroomRecord(id: document.documentID, product: product, productIcon: productIcon, taskDate: taskDate.dateValue(), userUID: userUID, size: size)
                    records.append(record)
                    if records.count == querySnapshot!.count {
                        completion(records)
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

