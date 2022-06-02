//
//  ChatLogView.swift
//  ChatSwiftUI
//
//  Created by Tzy on 30.11.2021.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import FirebaseFirestoreSwift

struct ChatLogView: View {
    
    static let scrollToString = "Empty"
    @State var nothing: Bool = false
    
    @ObservedObject var viewModel: ChatLogViewModel
    
    var body: some View {
        VStack {
            messagesView
        }
        .onAppear {
            viewModel.fetchMessages()
        }
        .onDisappear {
            viewModel.firestoreListener?.remove()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                CustomNavigationView(url: viewModel.getProfileImageString(),
                                     title: viewModel.getName(),
                                     actionImage: "",
                                     shouldToggleAction: $nothing)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messagesView: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(viewModel.chatMessages) { message in
                            MessageBubbleView(message: message)
                        }
                        
                        HStack{ Spacer() }
                        .id(Self.scrollToString)
                    }
                    .onReceive(viewModel.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            scrollViewProxy.scrollTo(Self.scrollToString, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .background(Color(.quaternaryLabel))
        .safeAreaInset(edge: .bottom) {
            chatBottomBar
                .background(Color(.systemBackground).ignoresSafeArea())
        }
    }
    
    private var chatBottomBar: some View {
        HStack {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.label))
                            TextEditor(text: $viewModel.chatText)
                .frame(minHeight: 24, idealHeight: 24, maxHeight: 48)
            Button {
                viewModel.handleSend()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(content: {
                withAnimation(.easeOut(duration: 0.3)) {
                    viewModel.chatText.isEmpty ? Color.blue.opacity(0.4) : Color.blue
                }
            })
            .cornerRadius(5)
            .disabled(viewModel.chatText.isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser? .uid {
                fromView
            } else {
                toView
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var fromView: some View {
            HStack {
                Spacer()
                HStack {
                    Text(message.text ?? String())
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }
    }
    
    private var toView: some View {
        HStack {
            HStack {
                Text(message.text ?? String())
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color(.purple))
            .cornerRadius(8)
            Spacer()
        }
    }
}


struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainMessagesView()
        }
    }
}
