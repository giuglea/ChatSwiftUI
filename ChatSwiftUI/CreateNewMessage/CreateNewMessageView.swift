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
    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(viewModel.users) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user.chatUser)
                        //TODO: Change here to add more users to the chat and do the job inside the viewmodel
                    } label: {
                        HStack {
                            WebImage(url: URL(string: user.chatUser.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50)
                                            .stroke(Color(.label), lineWidth: 1)
                                )
                                .shadow(radius: 5)
                            
                            Text(user.chatUser.email)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    
                    Divider()
                }
            }.navigationTitle("New Message")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                        
                    }
                }
        }
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewMessageView(viewModel: CreateNewMessageViewModel(firebaseManager: FirebaseManagerImplementation())) { _ in
        }
    }
}
