//
//  AuthenticationView.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/23/24.
//

import SwiftUI
import AuthenticationServices
import NeedleTailCrypto

struct AuthenticationView: View {
    
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @State var username: String = ""
    @State var password: String = ""
    @State var confirmedPassword: String = ""
    @State var isRegistered = false
    @State var isChecked: Bool = false
    @State var showAlert: Bool = false
    @State var appleIdentifier: String?
    
    let crypto = NeedleTailCrypto()
    
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
                        authenticationViewModel.state = .notRegistered
                        Task.detached {
                            try await loadCredentials()
                            await authenticateWithCredentials()
                        }
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
                SignInWithAppleButton { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        Task.detached {
                            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
                            guard let data = appleIDCredential.identityToken else {return}
                            let appleIDString = String(decoding: data, as: UTF8.self)
                            await MainActor.run {
                                authenticationViewModel.state = .notRegistered
                            }
                            try await loadCredentials()
                            //This means that we already have an appleIdentifier so we do not need to register our token, we just need to login to our server with the new appleIDString.
                            if let appleIdentifier = await appleIdentifier, !appleIdentifier.isEmpty {
                                await authenticateWithApple(appleIdentity: appleIDString)
                            } else {
                                //We do not have an identifier on our server yet, we will register
                                await authenticateWithApple(appleIdentity: appleIDString)
                            }
                        }
                        
                    case .failure(let error):
                        print(error)
                    }
                }
                .frame(height: 55)
                .padding()
            }
            .padding()
            .navigationTitle("Trekker")
        }
        .onAppear {
            Task.detached {
                try await loadCredentials()
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK") {
                showAlert.toggle()
            }
        } message: {
            Text("Please check authentication details")
        }
    }
    
    func authenticateWithCredentials() async  {
        await authenticationViewModel.authenticate(
            isRegistered: isRegistered,
            username: username,
            password: password,
            confirmPassword: confirmedPassword)
    }
    
    func loadCredentials() async throws {
        guard authenticationViewModel.state != .unauthenticated else { return }
        guard let item = await crypto.fetchKeychainItem(configuration: .init(service: "user-credentials-srervice")) else { return }
        guard let data = Data(base64Encoded: item) else { return }
        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
        await MainActor.run {
            //First Check if we have an apple id so we can sign in with apple
            if let appleIdentifier = decoded.user.appleIdentifier {
                self.appleIdentifier = appleIdentifier
                isRegistered = true
                authenticationViewModel.state = .authenticated
                return
            }
            //We also allow the option to login/register with passwords
            if let hash = decoded.user.passwordHash, !hash.isEmpty {
                isRegistered = true
                authenticationViewModel.state = .authenticated
            } else {
                isRegistered = false
            }
        }
    }
    
    func authenticateWithApple(appleIdentity: String) {
        Task.detached {
            await authenticationViewModel.signInWithApple(isRegistered: isRegistered, appleIdentity: appleIdentity)
        }
    }
}

#Preview {
    AuthenticationView(authenticationViewModel: .init())
}
