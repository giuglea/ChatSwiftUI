//
//  CustomNavigationView.swift
//  ChatSwiftUI
//
//  Created by GigiFullSpeed on 09.04.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct CustomNavigationView: View {
    var url: String?
    var title: String?
    @Binding var shouldToggleAction: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            WebImage(url: URL(string: url ?? String()))
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .scaledToFill()
                .frame(width: 35, height: 35)
                .cornerRadius(35)
                .overlay(RoundedRectangle(cornerRadius: 35)
                    .stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 3)

            VStack(alignment: .leading, spacing: 4) {
                Text(title ?? "")
                    .font(.system(size: 16, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
        }
        
    }
}
