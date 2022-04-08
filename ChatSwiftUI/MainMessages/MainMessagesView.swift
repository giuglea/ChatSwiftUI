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
    @State var chatUser: ChatUser?
    
    @StateObject var viewModel = MainMessagesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Divider()
                    .ignoresSafeArea(.all, edges: .horizontal)
                    .padding(.vertical, 5)
                messagesView
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    if let chatUser = chatUser {
                        let chatLogViewModel = ChatLogViewModel(chatUser: chatUser)
                        ChatLogView(viewModel: chatLogViewModel)
                    } else {
                        Text("Please select an user")
                    }
                }
            }
            .overlay(newMessageButton, alignment: .bottom)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    CustomNavigationView(url: viewModel.chatUser?.profileImageUrl,
                                         title: viewModel.chatUser?.email,
                                         shouldToggleAction: $shouldShowLogOutOptions)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .actionSheet(isPresented: $shouldShowLogOutOptions) {
                .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                    .destructive(Text("Sign Out"), action: {
                        viewModel.handleSignOut()
                    }),
                    .cancel()
                ])
            }
            .fullScreenCover(isPresented: $viewModel.isUserCunrentlyLoggedOut) {
                LogInView {
                    self.viewModel.isUserCunrentlyLoggedOut = false
                    self.viewModel.fetchCurrentUser()
                    self.viewModel.fetchRecentMessages()
                }
            }
        }
    }
    
    private var messagesView: some View {
        List(viewModel.recentMessages) { recentMessage in
            VStack {
                Button {
                    let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromID ?
                    recentMessage.toID : recentMessage.fromID

                    self.chatUser = .init(data: [
                        FirebaseConstants.email: recentMessage.email,
                        FirebaseConstants.profileImageURL: recentMessage.profileImageUrl,
                        FirebaseConstants.uid: uid
                    ])
                    self.shouldNavigateToChatLogView.toggle()
                } label: {
                    HStack(spacing: 16) {
                        WebImage(url: URL(string: recentMessage.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 45, height: 45)
                            .clipped()
                            .cornerRadius(45)
                            .overlay(RoundedRectangle(cornerRadius: 45).stroke(Color.init(.label), lineWidth: 1))
                            .shadow(radius: 5)
                        
                        VStack(alignment: .leading) {
                            Text(recentMessage.email)
                                .font(.system(size: 16, weight: .bold))
                                .multilineTextAlignment(.leading)
                            Text(recentMessage.text)
                                .font(.system(size: 14))
                                .foregroundColor(Color(.lightGray))
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        
                        Text(recentMessage.timeAgo)
                            .font(.system(size: 14, weight: .semibold))
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.fetchRecentMessages()
        }
    }
    
    private var newMessageButton: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        .padding(.bottom)
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView { user in
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
            }
        }
        
    }
}

//struct MainMessagesView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainMessagesView()
//    }
//}
