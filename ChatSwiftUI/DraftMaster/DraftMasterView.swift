//
//  DraftMasterView.swift
//  ChatSwiftUI
//
//  Created by GigiFullSpeed on 10.04.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct DraftMasterView: View {
    @StateObject var viewModel: DraftMasterViewModel
    @FocusState private var keyboardDismiss: Bool
    
    @State private var copied = false {
         didSet {
             if copied == true {
                 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                     withAnimation {
                         copied = false
                     }
                 }
             }
         }
     }
    
    var body: some View {
        ZStack {
            VStack {
                Text("Share with other users")
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.users) { user in
                            Button {
        //                        didSelectNewUser(user)
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
                    }
                }
                .frame(height: 60)
                
                HStack {
                    TextEditor(text: $viewModel.message)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.label), lineWidth: 1))
                        .frame(minHeight: 24, idealHeight: 24, maxHeight: 48)
                        .focused($keyboardDismiss)
                    
                    Button {
                        withAnimation {
                            copied = true
                            keyboardDismiss.toggle()
                        }
                        UIPasteboard.general.string = viewModel.message
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }

                }
            }
            .padding()
            
            clipboardMessage
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var clipboardMessage: some View {
        GeometryReader { geometry in
            ZStack {
                if copied {
                    Text("Copied to clipboard")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.cornerRadius(10))
                        .position(x: geometry.frame(in: .local).width / 2)
                        .transition(.move(edge: .top))
                        .padding(.top)
                        .animation(Animation.easeInOut(duration: 1), value: 1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

//struct DraftMasterView_Previews: PreviewProvider {
//    static var previews: some View {
//        DraftMasterView(viewModel: DraftMasterViewModel(firebaseManager: FirebaseManagerImplementation()))
//    }
//}
