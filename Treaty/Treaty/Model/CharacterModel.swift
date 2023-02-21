//
//  Character.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/21/23.
//

import SwiftUI

// MARK: Character Model For Holding Data about Each Alphabet
struct CharacterModel: Identifiable{
    var id: String = UUID().uuidString
    var value: String
    var index: Int = 0
    var rect: CGRect = .zero
    var pusOffset: CGFloat = 0
    var isCurrent: Bool = false
    var color: Color = .clear
}

