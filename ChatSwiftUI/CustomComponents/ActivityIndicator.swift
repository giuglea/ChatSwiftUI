//
//  ActivityIndicator.swift
//  ChatSwiftUI
//
//  Created by Tzy on 05.06.2022.
//

import SwiftUI

struct ActivityIndicator: View {
    
    @Binding var isAnimating: Bool
    
    var color: Gradient = Gradient(colors: [.pink, .purple, .blue])
    var backgroundColor: Color = .gray.opacity(0.3)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            VStack {
                GeometryReader { (geometry: GeometryProxy) in
                    ForEach(0..<7) { index in
                        Group {
                            Circle()
                                .foregroundColor(.clear)
                                .background(LinearGradient(gradient: color, startPoint: .leading, endPoint: .trailing))
                                .frame(width: geometry.size.width / 5, height: geometry.size.height / 5)
                                .cornerRadius(geometry.size.width / 5)
                                .scaleEffect(calcScale(index: index))
                                .offset(y: calcYOffset(geometry))
                        }
                        .background(LinearGradient(gradient: color, startPoint: .leading, endPoint: .trailing))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(360))
                        .animation(Animation
                            .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
                            .repeatForever(autoreverses: false), value: isAnimating)
                    }
                }
                .frame(width: 50, height: 50)
                
                Text("Loading...")
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(.all, 12)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(10)
        }
    }
    
    func calcScale(index: Int) -> CGFloat {
        return (!isAnimating ? 1 - CGFloat(Float(index)) / 5 : 0.2 + CGFloat(index) / 5)
    }
    
    func calcYOffset(_ geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width / 10 - geometry.size.height / 2
    }
    
}

//struct ActivityIndicator_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityIndicator()
//            .frame(width: 50, height: 50)
//            .foregroundColor(.pink)
//    }
//}
