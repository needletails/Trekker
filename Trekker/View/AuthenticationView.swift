//
//  AuthenticationView.swift
//  Trekker
//
//  Created by Cole M on 12/23/24.
//

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @State var username: String = ""
    @State var password: String = ""
    @State var confirmedPassword: String = ""
    @State var isRegistered = false
    @State var isChecked: Bool = false
    @State var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
                VStack {
                    Spacer()
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            TextField(text: $username) {
                                Text("Username")
                            }
                            .padding()
                            .border(Color.black)
                            .cornerRadius(8)
                            SecureField(text: $password) {
                                Text("Password")
                            }
                            .padding()
                            .border(Color.black)
                            .cornerRadius(8)
                            SecureField(text: $confirmedPassword) {
                                Text("Confrim Password")
                            }
                            .padding()
                            .border(Color.black)
                            .cornerRadius(8)
                        }
                        .frame(height: geometry.size.height * 0.7)
                    }
                    HStack {
                        Toggle("", isOn: $isChecked)
                            .labelsHidden()
                        Spacer()
                        Text("I agree to the Terms of Service and Privacy Policy")
                    }
                    Button(action: {
                        if password == confirmedPassword && isChecked {
                            authenticateWithCredentials()
                        } else {
                            showAlert.toggle()
                        }
                    }) {
                        Text(isRegistered ? "Login" : "Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue) // Background color for the button
                            .cornerRadius(8) // Rounded corners
                    }
                    .padding()
                    SignInWithAppleButton { requestId in
                        print("REQUEST ID", requestId)
                        authenticateWithApple()
                    } onCompletion: { result in
                        print("RESULT", result)
                    }
                    .frame(height: 55)
                    .padding()
                }
                .padding()
                .navigationTitle("Trekker")
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK") {
                showAlert.toggle()
            }
        } message: {
            Text("Please check authentication details")
        }
    }
    
    func authenticateWithCredentials() {
        Task.detached {
            await authenticationViewModel.authenticate(isRegistered: isRegistered)
        }
    }
    
    func authenticateWithApple() {
        Task.detached {
            await authenticationViewModel.signInWithApple(isRegistered: isRegistered)
        }
    }
}

#Preview {
    AuthenticationView(authenticationViewModel: .init())
}
