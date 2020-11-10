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
    @State var userId = UserDefaults.standard.integer(forKey: "userId")
    @State var displayAlert = false
    @State var alertMessage = ""
    @State var sending = false
    
    var body: some View {
        GeometryReader { metrics in
            VStack{
            ScrollView(.vertical){
                VStack{
                    ZStack{
                        if (self.newText == ""){
                            Text("Type...")
                                .foregroundColor(.gray)
                                .offset(x: -(metrics.size.width/2) + 50, y: 0)
                        }
                        ZStack{
                            TextEditor(text: $newText)
                                .foregroundColor(.white)
                            Text(newText).opacity(0).padding(.all, 8)
                        }
                        .opacity(self.newText == "" ? 0.5 : 1)
                    }
                    
                    .padding()
                    
                    if (self.image != UIImage()){
                        Image(uiImage: self.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: metrics.size.width * 0.9, height: metrics.size.width * 0.55)
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
                            .fontWeight(.semibold)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(Color.black)
                }
            }
            .blur(radius: sending ? 5 : 0)
            //$ to jest binding
            .alert(isPresented: $displayAlert, content: {
                Alert(
                    title: Text("Result"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")))
            })
        }
        .navigationBarTitle("Create", displayMode: .inline)
        .navigationBarItems(
            trailing:
                Button(action: {
                    createPost()
                }, label: {
                    Image(systemName: "paperplane.circle")
                        .font(.system(size: 23))
                }))
        .sheet(isPresented: $isShowPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                .preferredColorScheme(.dark)
        }
    }
    
    func convertImageToBase64String (img: UIImage) -> String {
        let base64 = img.jpegData(compressionQuality: 0.5)?.base64EncodedString()
        if base64 == nil {
            return ""
        } else {
            return "data:image/jpeg;base64," + base64!
        }
    }
    
    func createPost(){
        self.sending = true
        Network.shared.apollo
            .perform(mutation: CreatePostMutation(text: newText, userId: userId, image: convertImageToBase64String(img: image))) { result in
                switch result {
                case .success(let graphQLResult):
                    if let postConnection = graphQLResult.data?.createPost {
                        self.newText = ""
                        self.image = UIImage()
                        let objectID = postConnection.id.components(separatedBy: "\"")
                        let url = "https://www.quicpos.com/post/" + objectID[1]
                        let data = URL(string: url)!
                        let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
                    }
                    if let errors = graphQLResult.errors {
                        self.alertMessage = errors
                            .map { $0.localizedDescription }
                            .joined(separator: "\n")
                    }
                case .failure(let error):
                    self.alertMessage = error.localizedDescription
                }
                self.sending = false
                if alertMessage != "" {
                    self.displayAlert = true
                }
            }
    }
}

struct Creator_Previews: PreviewProvider {
    static var previews: some View {
        Creator()
    }
}
