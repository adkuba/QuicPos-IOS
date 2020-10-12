//
//  Creator.swift
//  QuicPos
//
//  Created by Kuba on 10/10/2020.
//

import SwiftUI

struct Creator: View {
    
    @State var newText = ""
    @State var isShowPhotoLibrary = false
    @State var image = UIImage()
    @State var userId = UserDefaults.standard.string(forKey: "userId")
    @State var displayAlert = false
    @State var alertMessage = ""
    
    var body: some View {
        GeometryReader { metrics in
            ZStack{
                Color.black
                
                
                VStack{
                    TextField("Enter text...", text: $newText)
                        .foregroundColor(.white)
                        .frame(width: metrics.size.width * 0.85, height: 200)
                    
                    Image(uiImage: self.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: metrics.size.width * 0.85, height: 200)
                        .clipped()
                    
                    HStack{
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                        
                        Button(action: {
                            self.isShowPhotoLibrary = true
                        }, label: {
                            Text("Select image")
                        })
                    }
                }
                //$ to jest binding
                .alert(isPresented: $displayAlert, content: {
                    Alert(
                        title: Text("Result"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK")))
                })
            }
        }
        .navigationBarItems(
            trailing:
                Button(action: {
                    createPost()
                }, label: {
                    Text("Send")
                }))
        .sheet(isPresented: $isShowPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
        }
    }
    
    func convertImageToBase64String (img: UIImage) -> String {
        let base64 = img.jpegData(compressionQuality: 1)?.base64EncodedString()
        if base64 == nil {
            return ""
        } else {
            return "data:image/jpeg;base64," + base64!
        }
    }
    
    func createPost(){
        Network.shared.apollo
            .perform(mutation: CreatePostMutation(text: newText, userId: userId!, image: convertImageToBase64String(img: image))) { result in
                switch result {
                case .success(let graphQLResult):
                    if let postConnection = graphQLResult.data?.createPost {
                        self.alertMessage = postConnection.id
                    }
                    if let errors = graphQLResult.errors {
                        self.alertMessage = errors
                            .map { $0.localizedDescription }
                            .joined(separator: "\n")
                    }
                case .failure(let error):
                    self.alertMessage = error.localizedDescription
                }
                self.displayAlert = true
            }
    }
}

struct Creator_Previews: PreviewProvider {
    static var previews: some View {
        Creator()
    }
}
