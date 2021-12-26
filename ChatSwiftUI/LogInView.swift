//
//  ContentView.swift
//  ChatSwiftUI
//
//  Created by Tzy on 15.11.2021.
//

import SwiftUI

struct LogInView: View {
    
    let didCompleteLogIn : () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var shouldShowImagePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label:
                            Text("Picker")) {
                        Text("Log in")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(.segmented)
                    
                    if !isLoginMode {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            
                            VStack {
                                if let image = image {
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
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                        .stroke(Color(.label), lineWidth: 3))
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
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
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .font(.system(size: 17, weight: .semibold))
                            Spacer()
                        }.background(.blue)
                            .cornerRadius(10)
                    }
                }.padding()
                
                Text(loginStatusMeesage)
                    .foregroundColor(.red)
                
            }.navigationTitle(isLoginMode ? "Login" : "Create Account")
                .background(Color.init(white: 0, opacity: 0.05)
                                .ignoresSafeArea())
        }.navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
    }
    
    @State var image: UIImage?
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    @State var loginStatusMeesage = ""
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.loginStatusMeesage = "Failed to log in user: \(error)"
                return
            }
            self.loginStatusMeesage = "Success log in: \(result?.user.uid ?? "")"
            didCompleteLogIn()
        }
    }
    
    private func createNewAccount() {
        if self.image == nil {
            self.loginStatusMeesage = "You must select an avatar image"
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.loginStatusMeesage = "Failed to create user: \(error)"
                return
            }
            self.loginStatusMeesage = "Success create: \(result?.user.uid ?? "")"
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                self.loginStatusMeesage = "Failed to save image \(error)"
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    self.loginStatusMeesage = "Failed to retreive download URL\(error)"
                    return
                }
                self.loginStatusMeesage = "Succes! \(url?.absoluteString ?? "")"
                guard let url = url else { return }
                self.storeUserInformation(imageProfileUrl: url)
            }
            
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": self.email,
                        "uid": uid,
                        "profileImageUrl": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { error in
                if let error = error {
                    print(error)
                    self.loginStatusMeesage = error.localizedDescription
                    self.didCompleteLogIn()
                }
            }
        
    }
}

struct ContentView_Previews2: PreviewProvider {
    static var previews: some View {
        LogInView {
        }
    }
}
