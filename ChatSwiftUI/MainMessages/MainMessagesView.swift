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
    
    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    
    var body: some View {
        NavigationView {
            
            VStack {
                customNavBar
                messagesView
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(viewModel: chatLogViewModel)
                }
            }
            .overlay(
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            WebImage(url: URL(string: viewModel.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 50)
                            .stroke(Color(.label), lineWidth: 1)
                )
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.chatUser?.email ?? "")
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
                
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
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
                    chatLogViewModel.chatUser = self.chatUser
                    chatLogViewModel.fetchMessages()
                    self.shouldNavigateToChatLogView.toggle()
                } label: {
                    HStack(spacing: 16) {
                        WebImage(url: URL(string: recentMessage.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipped()
                            .cornerRadius(64)
                            .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color.init(.label), lineWidth: 1))
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
                self.chatLogViewModel.chatUser = user
                self.chatLogViewModel.fetchMessages()
            }
        }
        
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}
