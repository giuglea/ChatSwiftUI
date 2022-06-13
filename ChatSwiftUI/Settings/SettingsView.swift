//
//  SettingsView.swift
//  ChatSwiftUI
//
//  Created by Tzy on 05.06.2022.
//

import SDWebImageSwiftUI
import SwiftUI

struct SettingsView: View {
    
    @StateObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.chatUser?.email ?? "")
                .font(.title)
            WebImage(url: URL(string: viewModel.chatUser?.profileImageUrl ?? String()))
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .scaledToFill()
                .frame(width: 100, height: 100)
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 50)
                    .stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 3)
            Text(viewModel.displayVersion)
                .opacity(0.8)
            Spacer()
            
            List(viewModel.settings) { setting in
                Button {
                    viewModel.didPressSetting(setting)
                } label: {
                    Text(setting.title)
                }
                .listRowSeparator(.hidden)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}


