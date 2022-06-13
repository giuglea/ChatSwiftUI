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
    @State var pickedImage: UIImage?
    @State var shouldShowImagePicker: Bool = false
    
    @ObservedObject var viewModel: ChatLogViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
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
            ToolbarItem(placement: .navigationBarLeading) {
                CustomNavigationView(url: viewModel.getProfileImageString(),
                                     title: viewModel.getName(),
                                     shouldToggleAction: $nothing)
            }
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $pickedImage)
        }
    }
    
    private var messagesView: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(viewModel.chatMessages) { message in
                            let type = message.fromId == viewModel.firebaseManager.auth.currentUser?.uid
                            MessageBubbleView(message: message, type: MessageType.getMessageType(from: type))
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
        .background(Color(.quaternaryLabel).ignoresSafeArea(.all, edges: .horizontal))
        .safeAreaInset(edge: .bottom) {
            chatBottomBar
        }
    }
    
    private var chatBottomBar: some View {
        HStack {
            Button {
                shouldShowImagePicker.toggle()
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.label))
                    .frame(width: 24, height: 24)
            }
            
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

fileprivate enum MessageType {
    case to
    case from
    
    static func getMessageType(from value: Bool) -> MessageType {
        value == true ? .from : .to
    }
}

fileprivate struct MessageBubbleView: View {
    let message: ChatMessage
    let type: MessageType
    
    var body: some View {
        VStack {
            switch type {
            case .from:
                fromView
            case .to:
                toView
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var fromView: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    Text(message.fromName)
                        .foregroundColor(.white.opacity(0.8))
                    Text(message.text ?? String())
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                .padding(.leading, 30)
            }
            if !(message.imageUrl?.isEmpty ?? true) {
                imageView
            }
        }
    }
    
    private var toView: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                VStack(spacing: 8) {
                    Text(message.fromName)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.trailing)
                    Text(message.text ?? String())
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color(.purple))
                .cornerRadius(8)
                .padding(.trailing, 30)
                Spacer()
            }
            if !(message.imageUrl?.isEmpty ?? true) {
                imageView
            }
        }
    }
    
    private var imageView: some View {
        WebImage(url: URL(string: message.imageUrl ?? ""))
            .resizable()
            .placeholder(content: {
                ProgressView()
            })
            .scaledToFill()
            .frame(width: 140, height: 140)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.label), lineWidth: 1))
            .shadow(radius: 3)
    }
}


//struct ChatLogView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            MainMessagesView()
//        }
//    }
//}
