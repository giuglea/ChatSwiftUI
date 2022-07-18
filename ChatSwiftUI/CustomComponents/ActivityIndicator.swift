//
//  ActivityIndicator.swift
//  ChatSwiftUI
//
//  Created by Tzy on 05.06.2022.
//

import SwiftUI
import ActivityIndicatorView

struct ActivityIndicator: View {
    
    @Binding var isAnimating: Bool
    var backgroundColor: Color = .gray.opacity(0.3)
    
    var body: some View {
        ZStack {
            VStack {
                ActivityIndicatorView(isVisible: $isAnimating, type: .rotatingDots(count: 5))
                    .foregroundColor(.purple)
                    .frame(width: 50, height: 50)
                Text("Loading...")
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(.all, 12)
            .background(Color.purple.opacity(0.3))
            .background(Material.ultraThick)
            .cornerRadius(10)
        }
        .background(Material.ultraThick)
        .ignoresSafeArea()
    }
}

#if DEBUG
struct ActivityIndicator_Previews: PreviewProvider {
    @State static var animate = true
    static var previews: some View {
        ActivityIndicator(isAnimating: $animate)
    }
}
#endif
