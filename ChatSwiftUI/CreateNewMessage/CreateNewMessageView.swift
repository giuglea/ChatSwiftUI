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
    
    let didSelectNewUser: (ChatModel) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    List(viewModel.users) { user in
                        ChatUserCell(user: user) {
                            viewModel.didSelectUser(with: user.id)
                        }
                    }
                    .listStyle(.plain)
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
                    didSelectUsersButton
                }
            }
            if viewModel.isLoading {
                ActivityIndicator(isAnimating: $viewModel.isLoading)
                    .ignoresSafeArea()
            }
        }
    }
    
    private var didSelectUsersButton: some View {
        VStack {
            TextField("Please enter the group's name", text: $viewModel.groupName)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.vertical, 6)
            
            Button {
                viewModel.shouldShowImagePicker.toggle()
            } label: {
                HStack {
                    Text("Please select an image: ")
                    Image(uiImage: viewModel.selectedImage ?? UIImage())
                        .resizable()
                        .scaledToFill()
                        .frame(width: 35, height: 35)
                        .cornerRadius(35)
                        .overlay(RoundedRectangle(cornerRadius: 35)
                            .stroke(Color(.label), lineWidth: 1))
                        .shadow(radius: 3)
                }

            }
            .padding(.horizontal, 16)
            .padding(.bottom)

            Button {
                viewModel.didTapCreateChat { model in
                    didSelectNewUser(model)
                    presentationMode.wrappedValue.dismiss()
                }
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
        .fullScreenCover(isPresented: $viewModel.shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $viewModel.selectedImage)
        }
    }
}

fileprivate struct ChatUserCell: View {
    
    let user: SelectableChatUser
    let onSelect: () -> ()
    
    var body: some View {
        Button {
            onSelect()
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
}


//struct CreateNewMessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateNewMessageView(viewModel: CreateNewMessageViewModel(firebaseManager: FirebaseManagerImplementation())) { _ in
//        }
//    }
//}
