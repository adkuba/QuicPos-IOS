//
//  Creator.swift
//  QuicPos
//
//  Created by Kuba on 10/10/2020.
//

import SwiftUI

struct Creator: View {
    
    @State var newText = "New post"
    @State var isShowPhotoLibrary = false
    @State var image = UIImage()
    @State var userId = UserDefaults.standard.string(forKey: "userId")
    @State var displayAlert = false
    @State var alertMessage = ""
    
    var body: some View {
        GeometryReader { metrics in
            VStack{
            ScrollView(.vertical){
                VStack{
                    ZStack{
                        TextEditor(text: $newText)
                        Text(newText).opacity(0).padding(.all, 8)
                    }
                    .padding()
                    
                    if (self.image != UIImage()){
                        Image(uiImage: self.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: metrics.size.width * 0.9, height: metrics.size.width * 0.5)
                            .clipped()
                            .cornerRadius(10)
                            .padding()
                    }
                }
            }
                Button(action: {
                    self.isShowPhotoLibrary = true
                }) {
                    HStack{
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                        
                        Text("Select image")
                    }
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(Color.blue)
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
        .navigationBarTitle(Text(""), displayMode: .inline)
        .navigationBarItems(
            trailing:
                Button(action: {
                    createPost()
                }, label: {
                    Text("Send")
                }))
        .sheet(isPresented: $isShowPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                .preferredColorScheme(.dark)
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
