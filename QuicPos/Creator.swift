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
            //TEXT AND IMAGE
            
            ScrollView(.vertical){
                VStack{
                    ZStack{
                        if (self.newText == ""){
                            Text("Type...")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                                .offset(x: -(metrics.size.width/2) + 50, y: 0)
                        }
                        ZStack{
                            TextEditor(text: $newText)
                                .font(.system(size: 18))
                            Text(newText).opacity(0).padding(.all, 8)
                                .font(.system(size: 18))
                        }
                        .opacity(self.newText == "" ? 0.5 : 1)
                    }
                    .padding()
                    
                    if (self.image != UIImage()){
                        Image(uiImage: self.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: metrics.size.width * 0.9)
                            .clipped()
                            .cornerRadius(10)
                            .padding()
                    }
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
            .toolbar{
                ToolbarItem(placement: .bottomBar){
                    //IMAGE BUTTON
                    Button(action: {
                        self.isShowPhotoLibrary = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                    }
                }
                ToolbarItem(placement: .bottomBar){
                    Spacer()
                }
                //CREATE POST
                ToolbarItem(placement: .bottomBar){
                    Button(action: {
                        createPost()
                    }, label: {
                        Image(systemName: "paperplane")
                    })
                }
            }
        }
        .navigationBarTitle("Create", displayMode: .inline)
        .navigationBarItems(
            trailing:
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }, label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .font(.system(size: 20))
                }))
        .sheet(isPresented: $isShowPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
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
