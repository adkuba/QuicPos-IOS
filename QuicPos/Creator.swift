//
//  Creator.swift
//  QuicPos
//
//  Created by Kuba on 10/10/2020.
//

import SwiftUI

struct Creator: View {
    
    @ObservedObject private var keyboard = KeyboardResponder()
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
                //TEXT AND IMAGE
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
                                Text(newText).opacity(0).padding(.all, 8)
                            }
                            .opacity(self.newText == "" ? 0.5 : 1)
                        }
                        
                        .padding()
                        
                        if (self.image != UIImage()){
                            Image(uiImage: self.image)
                                .resizable()
                                .scaledToFill()
                                .cornerRadius(5)
                                .padding()
                                .frame(width: metrics.size.width)
                                .clipped()
                        }
                    }
                }
                .frame(height: keyboard.currentHeight == CGFloat(0) ? metrics.size.height : metrics.size.height - 45)
                HStack{
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        self.isShowPhotoLibrary = true
                    }) {
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }, label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 20))
                    })
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        createPost()
                    }, label: {
                        Image(systemName: "paperplane")
                            .font(.system(size: 20))
                    })
                    .padding()
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 40)
                .opacity(keyboard.currentHeight == CGFloat(0) ? 0 : 1)
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
        .toolbar(content: {
            ToolbarItem(placement: .bottomBar){
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    self.isShowPhotoLibrary = true
                }) {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                }
            }
            ToolbarItem(placement: .bottomBar){
                Spacer()
            }
            ToolbarItem(placement: .bottomBar){
                Button(action: {
                    createPost()
                }, label: {
                    Image(systemName: "paperplane")
                        .font(.system(size: 20))
                })
            }
        })
        .navigationBarTitle("Create", displayMode: .inline)
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
        let data = AppValues()
        
        Network.shared.apollo
            .perform(mutation: CreatePostMutation(text: newText, userId: userId, image: convertImageToBase64String(img: image), password: data.password)) { result in
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
                        
                        var postids = UserDefaults.standard.stringArray(forKey: "myposts") ?? [String]()
                        if !postids.contains(objectID[1]) {
                            postids.append(objectID[1])
                            UserDefaults.standard.set(postids, forKey: "myposts")
                        }
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


final class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}
