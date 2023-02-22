//
//  Breed.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/19/23.
//

import SwiftUI

struct Breed: Identifiable{
    var id: String = UUID().uuidString
    var value: String
    var index: Int = 0
    var rect: CGRect = .zero
    var pusOffset: CGFloat = 0
    var isCurrent: Bool = false
    var color: Color = .clear
}
