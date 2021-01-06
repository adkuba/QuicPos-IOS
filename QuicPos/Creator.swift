//
//  Creator.swift
//  QuicPos
//
//  Created by Kuba on 10/10/2020.
//

import SwiftUI

enum ActiveSheet {
   case first, second
}

struct Creator: View {
    
    @ObservedObject private var keyboard = KeyboardResponder()
    @State var newText = ""
    @State private var activeSheet: ActiveSheet = .first
    @State var image = UIImage()
    @State var userId = UserDefaults.standard.string(forKey: "user") ?? ""
    @State var displayAlert = false
    @State var alertMessage = ""
    @State var sending = false
    @State var showingSheet = false
    @State var url = ""
    
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
                        self.showingSheet = true
                        self.activeSheet = .first
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
                            .font(.system(size: 19))
                    })
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        createPost()
                    }, label: {
                        Image(systemName: "paperplane")
                            .font(.system(size: 19))
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
                    title: Text("Info"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")))
            })
        }
        .navigationBarItems(trailing:
                                Button(action: {
                                    self.alertMessage = userId + " your ID. Save it to delete posts after uninstall. Contact admin@tline.site"
                                    self.displayAlert = true
                                }, label: {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 19))
                                }))
        .toolbar(content: {
            ToolbarItem(placement: .bottomBar){
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    self.showingSheet = true
                    self.activeSheet = .first
                }) {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                }
            }
            ToolbarItem(placement: .bottomBar){
                Spacer()
            }
            ToolbarItem(placement: .bottomBar){
                Text("Create post")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
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
        .sheet(isPresented: $showingSheet) {
            if self.activeSheet == .first {
                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
            } else {
                ActivityView(activityItems: [NSURL(string: url)!] as [Any], applicationActivities: nil)
            }
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
        
        if newText == "" {
            self.alertMessage = "Type text!"
            self.displayAlert = true
            return
        }
        
        if userId == "" {
            self.alertMessage = "Bad user ID, reset app?"
            self.displayAlert = true
            return
        }
        
        self.alertMessage = ""
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
                        self.url = "https://www.quicpos.com/post/" + objectID[1]
                        self.showingSheet = true
                        self.activeSheet = .second
                        
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


struct ActivityView: UIViewControllerRepresentable {

    let activityItems: [Any]
    let applicationActivities: [UIActivity]?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
    return UIActivityViewController(activityItems: activityItems,
                                    applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ActivityView>) {

    }
}
