//
//  CreateNewMessageView.swift
//  ChatSwiftUI
//
//  Created by Tzy on 27.11.2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct CreateNewMessageView: View {
    
    @ObservedObject var viewModel: CreateNewMessageViewModel
    let didSelectNewUser: ([ChatUser]) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(viewModel.users) { user in
                Button {
                    viewModel.didSelectUser(with: user.id)
                    //TODO: Change here to add more users to the chat and do the job inside the viewmodel
                } label: {
                    HStack {
                        ZStack {
                            ZStack {
                                WebImage(url: URL(string: user.chatUser.profileImageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .opacity(user.isSelected ? UIConstants.Alpha.disabledComponent : UIConstants.Alpha.normalComponent)
                            }
                            .frame(width: 36, height: 36)
                            .clipped()
                            .cornerRadius(36)
                            .overlay(RoundedRectangle(cornerRadius: 36)
                                .stroke(Color(.label), lineWidth: 1)
                            )
                            .shadow(radius: 4)
                            if user.isSelected {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .padding(.all, 4)
                                    .frame(width: 36, height: 36)
                                    .clipped()
                                    .cornerRadius(36)
                            }
                        }
                        Text(user.chatUser.email)
                        Spacer()
                    }
                }
                .listRowSeparator(.hidden)
            }
            .navigationTitle("New Group")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    
                }
            }
            .overlay(didSelectUsersButton, alignment: .bottom)
        }
    }
    
    private var didSelectUsersButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
            didSelectNewUser(viewModel.users.map { $0.chatUser })
        } label: {
            Image(systemName: "person.fill.badge.plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 36)
                .foregroundColor(.white)
                .padding(16)
        }
        .background(.blue)
        .cornerRadius(10)
        .disabled(!viewModel.canCreateChat)
        .opacity(!viewModel.canCreateChat ? UIConstants.Alpha.disabledComponent : UIConstants.Alpha.normalComponent)
    }
}

//struct CreateNewMessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateNewMessageView(viewModel: CreateNewMessageViewModel(firebaseManager: FirebaseManagerImplementation())) { _ in
//        }
//    }
//}
