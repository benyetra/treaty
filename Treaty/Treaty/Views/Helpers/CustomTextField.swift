//
//  CustomTextField.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI

struct CustomTextField: View {
    var hint: String
    @Binding var text: String
    
    // MARK: View Properties
    @Environment(\.colorScheme) private var colorScheme
    @FocusState var isEnabled: Bool
    var contentType: UITextContentType = .telephoneNumber
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextField(hint, text: $text)
                .keyboardType(.numberPad)
                .textContentType(contentType)
                .focused($isEnabled)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill((colorScheme == .light ? Color.black : Color.white).opacity(0.2))
                
                Rectangle()
                    .fill(colorScheme == .light ? Color.white : Color.black)
                    .frame(width: isEnabled ? nil : 0,alignment: .leading)
                    .animation(.easeInOut(duration: 0.3), value: isEnabled)
            }
            .frame(height: 2)
        }
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
