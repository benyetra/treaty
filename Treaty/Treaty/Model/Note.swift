//
//  Task.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/2/23.
//

import SwiftUI

// note Model and Sample Tasks...
// Array of notes...
struct Note: Identifiable{
    var id = UUID().uuidString
    var title: String
    var time: Date = Date()
}

// Total note Meta View...
struct NoteMetaData: Identifiable{
    var id = UUID().uuidString
    var note: [Note]
    var noteDate: Date
}

// sample Date for Testing...
func getSampleDate(offset: Int)->Date{
    let calender = Calendar.current
    
    let date = calender.date(byAdding: .day, value: offset, to: Date())
    
    return date ?? Date()
}

// Sample Tasks...
var notes: [NoteMetaData] = [

    NoteMetaData(note: [
    
        Note(title: "Talk to iJustine"),
        Note(title: "iPhone 13 Great Design Change😂"),
        Note(title: "Nothing Much Workout !!!")
    ], noteDate: getSampleDate(offset: 1)),
    NoteMetaData(note: [
        
        Note(title: "Talk to Jenna Ezarik")
    ], noteDate: getSampleDate(offset: -3)),
    NoteMetaData(note: [
        
        Note(title: "Meeting with Tim Cook")
    ], noteDate: getSampleDate(offset: -8)),
    NoteMetaData(note: [
        
        Note(title: "Next Version of SwiftUI")
    ], noteDate: getSampleDate(offset: 10)),
    NoteMetaData(note: [
        
        Note(title: "Nothing Much Workout !!!")
    ], noteDate: getSampleDate(offset: -22)),
    NoteMetaData(note: [
        
        Note(title: "iPhone 13 Great Design Change😂")
    ], noteDate: getSampleDate(offset: 15)),
    NoteMetaData(note: [
        
        Note(title: "Kavsoft App Updates....")
    ], noteDate: getSampleDate(offset: -20)),
]
