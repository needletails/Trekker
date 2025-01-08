//
//  EditProfile.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/23/24.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct EditProfile: View {
    
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @State private var username: String = ""
    @State private var nickname: String = ""
    @State private var profilePhoto: Image? = nil
    @State private var showImagePicker: Bool = false
#if canImport(UIKit)
    @State private var selectedImage: UIImage? = nil
#elseif canImport(AppKit)
    @State private var selectedImage: NSImage? = nil
#endif
    @State private var showSuccessAlert: Bool = false
    
    var body: some View {
        NavigationView {
                Form {
                    Section(header: Text(username)) {
                        HStack {
                            if let profilePhoto = profilePhoto {
                                profilePhoto
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(alignment: .bottomTrailing) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "pencil")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(.white)
                                                .frame(width: 20, height: 20)
                                        }
                                        .onTapGesture {
                                            showImagePicker = true
                                        }
                                        .padding(5)
                                    }
                                
                            } else {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 100, height: 100)
                                    .overlay(alignment: .bottomTrailing) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "pencil")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(.white)
                                                .frame(width: 20, height: 20)
                                        }
                                        .onTapGesture {
                                            showImagePicker = true
                                        }
                                        .padding(5)
                                    }
                            }
                        }
                        TextField("Nickname", text: $nickname)
                    }
 
                        Button {
                            Task {
                                try await saveProfile()
                            }
                        } label: {
                            Text("Save Changes")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .listRowBackground(Color.black)
            }
            .navigationTitle("Edit Profile")
            .alert("Success", isPresented: $showSuccessAlert, actions: {
                Button {
                    showSuccessAlert = false
                } label: {
                    Text("Dismiss")
                }

            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onChange(of: selectedImage) { oldImage, newImage in
                if let newImage = newImage {
#if canImport(UIKit)
                    profilePhoto = Image(uiImage: newImage)
#elseif canImport(AppKit)
                    profilePhoto = Image(nsImage: newImage)
#endif
                }
            }
        }
        .onAppear {
            do {
                if let user = authenticationViewModel.user, let metadata = user.metadata {
                    self.username = user.username
                    let metadata = try JSONDecoder().decode(UserMetadata.self, from: metadata)
#if canImport(UIKit)
                    guard let image = UIImage(data: metadata.profilePhoto) else { return }
                    self.nickname = metadata.nickname
                    self.profilePhoto = Image(uiImage: image)
#elseif canImport(AppKit)
                guard let image = NSImage(data: metadata.profilePhoto) else { return }
                self.nickname = metadata.nickname
                self.profilePhoto = Image(nsImage: image)
#endif
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func saveProfile() async throws {
#if canImport(UIKit)
        let photoData = self.selectedImage?.pngData()
        let metadata = UserMetadata(id: UUID(), nickname: self.nickname, profilePhoto: photoData ?? Data())
        let data = try JSONEncoder().encode(metadata)
        await authenticationViewModel.updateUserMetadata(data: data)
        showSuccessAlert = true
#elseif canImport(AppKit)
        
#endif
    }
}

#if canImport(UIKit)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
#elseif canImport(AppKit)
struct ImagePicker: NSViewControllerRepresentable {
    @Binding var image: NSImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSViewController(context: Context) -> NSViewController {
        let viewController = NSViewController()
        return viewController
    }

    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}

    func openImagePicker() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .gif]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false

        panel.begin { response in
            if response == .OK, let url = panel.url {
                if let image = NSImage(contentsOf: url) {
                    self.image = image
                }
            }
        }
    }

    class Coordinator: NSObject {
        var parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
    }
}


#endif

#Preview {
    EditProfile()
}
