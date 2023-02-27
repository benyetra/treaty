//
//  CarouselView.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/24/23.
//

import SwiftUI

struct CarouselView<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let content: Content

    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 5) {
                content
                    .frame(width: geometry.size.width)
            }
            .offset(x: -CGFloat(currentIndex) * geometry.size.width)
            .animation(.easeInOut(duration: 0.3))
            .gesture(
                DragGesture()
                    .onEnded({ value in
                        let offset = value.translation.width
                        let newIndex = Int((CGFloat(currentIndex) * geometry.size.width - offset) / geometry.size.width)
                        currentIndex = min(max(newIndex, 0), pageCount - 1)
                    })
            )
        }
    }
}
