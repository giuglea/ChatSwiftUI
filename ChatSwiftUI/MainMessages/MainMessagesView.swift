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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Messages")
                    .font(.title)
                    .fontWeight(.heavy)
            }
        }
        .searchable(text: $viewModel.searchText)
        .navigationTitle("")
    }
    
    private var messagesView: some View {
        List(viewModel.displayedGroups) { recentChat in
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
                            .shadow(radius: 4)

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
            viewModel.onRefresh()
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
                    .frame(width: 36, height: 36)
                    .foregroundColor(.white)
                    .padding(16)
            }
            .background(.blue)
            .cornerRadius(40)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 26)
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            let viewModel = CreateNewMessageViewModel(firebaseManager: viewModel.firebaseManager)
            CreateNewMessageView(viewModel: viewModel) { users in
                self.shouldNavigateToChatLogView.toggle()
                guard let currentUser = viewModel.firebaseManager.getCurrentUser() else { return }
                let chatId = viewModel.firebaseManager.generateNewChatId()
                var participants = users
                participants.append(currentUser)
                
                let chatModel = ChatModel(id: chatId,
                                          groupName: chatId,
                                          participants: participants,
                                          participantsNames: participants.map { $0.email },
                                          imageUrl: currentUser.profileImageUrl,
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
