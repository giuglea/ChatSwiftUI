//
//  CreateNewMessageView.swift
//  ChatSwiftUI
//
//  Created by Tzy on 27.11.2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct CreateNewMessageView: View {
    
    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(viewModel.users) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                        //TODO: Change here to add more users to the chat and do the job inside the viewmodel
                    } label: {
                        HStack {
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50)
                                            .stroke(Color(.label), lineWidth: 1)
                                )
                                .shadow(radius: 5)
                            
                            Text(user.email)
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
        CreateNewMessageView { _ in
        }
    }
}
