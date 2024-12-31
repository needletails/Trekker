//
//  EditProfile.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/23/24.
//

import SwiftUI

import SwiftUI

struct EditProfile: View {
    
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @State private var username: String = ""
    @State private var nickname: String = ""
    @State private var profilePhoto: Image? = nil
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage? = nil
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
                    profilePhoto = Image(uiImage: newImage)
                }
            }
        }
        .onAppear {
            do {
//                if
                let user = authenticationViewModel.user 
                    self.username = user.username
                    let metadata = try JSONDecoder().decode(UserMetadata.self, from: user.metadata)
                    guard let image = UIImage(data: metadata.profilePhoto) else { return }
                    self.nickname = metadata.nickname
                    self.profilePhoto = Image(uiImage: image)
//                }
            } catch {
                print(error)
            }
        }
    }
    
    private func saveProfile() async throws {
        let photoData = self.selectedImage?.pngData()
        let metadata = UserMetadata(id: UUID(), nickname: self.nickname, profilePhoto: photoData ?? Data())
        let data = try JSONEncoder().encode(metadata)
        await authenticationViewModel.updateUserMetadata(data: data)
        showSuccessAlert = true
    }
}

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

#Preview {
    EditProfile()
}
