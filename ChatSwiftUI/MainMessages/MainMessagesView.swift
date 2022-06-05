//
//  MainMessagesView.swift
//  ChatSwiftUI
//
//  Created by Tzy on 16.11.2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var shouldNavigateToChatLogView = false
    @State var shouldShowNewMessageScreen = false
    @State var showDraft = false
    @State var chatModel: ChatModel?
    @State var navigationTitle = "Messages"
    
    @ObservedObject var viewModel: MainMessagesViewModel
    
    var body: some View {
        VStack {
            messagesView
            NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                if let chatModel = chatModel {
                    let chatLogViewModel = ChatLogViewModel(chatModel: chatModel,
                                                            firebaseManager: viewModel.firebaseManager)
                    ChatLogView(viewModel: chatLogViewModel)
                } else {
                    Text("Please select an user")
                }
            }
        }
        .overlay(newMessageButton, alignment: .bottom)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                CustomNavigationView(url: viewModel.chatUser?.profileImageUrl,
//                                     title: viewModel.chatUser?.email,
//                                     shouldToggleAction: $shouldShowLogOutOptions)
//            }
//        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Messages")
    }
    
    private var messagesView: some View {
        List(viewModel.recentGroups) { recentChat in
            VStack {
                Button {
                    self.chatModel = recentChat
                    self.shouldNavigateToChatLogView.toggle()
                } label: {
                    HStack(spacing: 16) {
                        WebImage(url: URL(string: recentChat.imageUrl ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 45, height: 45)
                            .clipped()
                            .cornerRadius(45)
                            .overlay(RoundedRectangle(cornerRadius: 45).stroke(Color.init(.label), lineWidth: 1))
                            .shadow(radius: 5)

                        VStack(alignment: .leading) {
                            Text(recentChat.groupName)
                                .font(.system(size: 16, weight: .bold))
                                .multilineTextAlignment(.leading)
                            Text(recentChat.lastMessage?.text ?? "")
                                .font(.system(size: 14))
                                .foregroundColor(Color(.lightGray))
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()

                        Text(recentChat.timeAgo)
                            .font(.system(size: 14, weight: .semibold))
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .refreshable {
            // TODO: check if another request is necessary
            viewModel.fetchRecentMessages()
        }
    }
    
    private var newMessageButton: some View {
        HStack {
            Spacer()
            Button {
                shouldShowNewMessageScreen.toggle()
            } label: {
                Image(systemName: "plus.message.fill")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundColor(.white)
                    .padding(16)
            }
            .background(.blue)
            .cornerRadius(40)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            let viewModel = CreateNewMessageViewModel(firebaseManager: viewModel.firebaseManager)
            CreateNewMessageView(viewModel: viewModel) { user in
                self.shouldNavigateToChatLogView.toggle()
                guard let currentUser = viewModel.firebaseManager.getCurrentUser() else { return }
                let chatModel = ChatModel(id: user.id,
                                          groupName: user.email,
                                          participants: [user, currentUser],
                                          participantsNames: [currentUser.email, user.email],
                                          imageUrl: user.profileImageUrl,
                                          lastMessage: nil,
                                          timeStamp: Date())
                self.chatModel = chatModel
            }
        }
    }
}

//struct MainMessagesView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainMessagesView()
//    }
//}
