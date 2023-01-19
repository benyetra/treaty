//
//  LoadingView.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI

struct LoadingView: View {
    @Binding var show: Bool
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        ZStack{
            if show{
                Group{
                    Rectangle()
                        .fill(colorScheme == .light ? Color.black : Color.white).opacity(0.25)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .padding(15)
                        .background(colorScheme == .light ? Color.white : Color.black, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: show)
    }
}

