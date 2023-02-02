//
//  DateValue.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/1/23.
//

import SwiftUI

// Date Value Model...
struct DateValue: Identifiable{
    var id = UUID().uuidString
    var day: Int
    var date: Date
}
