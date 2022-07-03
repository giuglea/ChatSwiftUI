//
//  ContentView.swift
//  ChatSwiftUI
//
//  Created by Tzy on 15.11.2021.
//

import SwiftUI

struct LogInView: View {
    @ObservedObject var viewModel: LogInViewModel
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: 16) {
                        Picker(selection: $viewModel.isLoginMode) {
                            Text("Log in")
                                .tag(true)
                            Text("Create Account")
                                .tag(false)
                        } label: {
                            Text("Picker")
                        }
                        .pickerStyle(.segmented)
                        
                        if !viewModel.isLoginMode {
                            Button {
                                viewModel.shouldShowImagePicker.toggle()
                            } label: {
                                VStack {
                                    if let image = viewModel.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 128, height: 128)
                                            .cornerRadius(64)
                                    } else {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 64))
                                            .padding()
                                            .foregroundColor(Color(.label))
                                    }
                                }
                                .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color(.label), lineWidth: 3))
                            }
                        }
                        
                        Group {
                            TextField("Email", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                            
                            SecureField("Password", text: $viewModel.password)
                                .textInputAutocapitalization(.never)
                        }
                        .textInputAutocapitalization(.never)
                        .padding(8)
                        .background(Color(.quaternaryLabel))
                        .cornerRadius(10)
                        
                        Button {
                            handleAction()
                        } label: {
                            HStack {
                                Spacer()
                                Text(viewModel.isLoginMode ? "Log In" : "Create Account")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .font(.system(size: 17, weight: .semibold))
                                Spacer()
                            }
                            .background(.blue)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    Text(viewModel.loginStatusMeesage)
                        .foregroundColor(.red)
                    
                }
                .navigationTitle(viewModel.isLoginMode ? "Login" : "Create Account")
                .background(Color.init(white: 0, opacity: 0.05).ignoresSafeArea())
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $viewModel.shouldShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $viewModel.image)
            }
            if viewModel.isLoading {
                ActivityIndicator(isAnimating: $viewModel.isLoading)
                    .ignoresSafeArea()
            }
        }
    }
    
    private func handleAction() {
        if viewModel.isLoginMode {
            viewModel.loginUser()
        } else {
            viewModel.createNewAccount()
        }
    }
}

//struct ContentView_Previews2: PreviewProvider {
//    static var previews: some View {
//        LogInView {
//        }
//    }
//}
