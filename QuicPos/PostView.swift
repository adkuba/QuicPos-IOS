//
//  PostView.swift
//  QuicPos
//
//  Created by Kuba on 06/10/2020.
//

import SwiftUI

struct Post {
    var ID: String?
    var text: String
    var userid: String?
    var image: String?
    var shares: Int?
    var views: Int?
    var creationTime: String?
    var loading: Bool?
    var blocked: Bool?
    var ad: Bool?
}

struct Helper {
    static var id = ""
}

struct PostView: View {
    
    var post: Post
    var selectedMode: String
    
    @State var userId = UserDefaults.standard.string(forKey: "user") ?? ""
    @State @ObservedObject var imageLoader = ImageLoader(urlString: "")
    @State var image:UIImage = UIImage()
    @State var displayImage = false
    @State var timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()
    @State var blurValue = CGFloat(0)
    @State var showingSheet = false
    let data = AppValues()
    
    @State var shareErrorMessage = ""
    @State var shareAlertShow = false
    @State var reportConfirmationAlertShow = false
    @State var reportMessage = ""
    @State var reportAlertShow = false
    @State var textParsed: [String] = []
    @State var confirmationBlockAlert = false
    @State var blockAlert = false
    @State var blockAlertMessage = ""

    var body: some View {
        GeometryReader { metrics in
            ScrollView{
                VStack{
                    //id
                    Spacer(minLength: 30)
                    HStack{
                        Text(((post.ad ?? false) ? "Promoted @" : "User @") + (post.userid ?? "auto").prefix(4))
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            self.confirmationBlockAlert = true
                            self.blockAlert = false
                        }, label: {
                            Text("Block")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        })
                        .alert(isPresented: $confirmationBlockAlert, content: {
                            if (blockAlert){
                                return Alert(title: Text("Block"), message: Text(blockAlertMessage))
                            } else {
                                return Alert(
                                    title: Text("Are you sure?"),
                                    message: Text("Do you really want to block this user? You can unblock by contacting us."),
                                    primaryButton: .destructive(Text("Yes"), action: blockUser),
                                    secondaryButton: .cancel(Text("No"))
                                )
                            }
                        })
                    }
                    .padding()
                    .frame(width: metrics.size.width, height: 17, alignment: .leading)
                    
                    //text
                    LinkedText(post.text)
                        .lineLimit(nil)
                        .padding()
                        .frame(width: metrics.size.width, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        
                    //image
                    if displayImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .cornerRadius(5)
                            .padding()
                            .frame(width: metrics.size.width)
                            .clipped()
                            .onReceive(imageLoader.didChange) { data in
                                self.image = UIImage(data: data) ?? UIImage()
                            }
                    }
                    
                    Spacer(minLength: 20)
                    
                    //stats
                    Text((post.creationTime ?? "20.10.2020 11:45").prefix(16))
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding()
                        .frame(width: metrics.size.width, height: 17, alignment: .leading)
            
                    Text(String(post.views ?? 0) + " views " + String(post.shares ?? 0) + " shares")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding()
                        .frame(width: metrics.size.width, height: 17, alignment: .leading)
                        .padding(.bottom, 10)
                    
                        
                    //action section
                    HStack{
                        Button(action: {
                            //share
                            reportShare()
                        }, label: {
                            HStack{
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 22))
                                Text("Share")
                                    .fontWeight(.semibold)
                                    .offset(x:0, y:4)
                            }
                        })
                        .foregroundColor(.primary)
                        .offset(x: 0, y: -4)
                        .alert(isPresented: $shareAlertShow, content: {
                            Alert(title: Text("Error"), message: Text(shareErrorMessage))
                        })
                            
                        Button(action: {
                            self.reportConfirmationAlertShow = true
                            self.reportAlertShow = false
                        }, label: {
                            HStack{
                                Image(systemName: "exclamationmark.bubble")
                                    .font(.system(size: 22))
                                Text("Report")
                                    .fontWeight(.semibold)
                            }
                        })
                        .foregroundColor(.primary)
                        .offset(x: 20, y: 0)
                        .alert(isPresented: $reportConfirmationAlertShow, content: {
                            if (reportAlertShow){
                                return Alert(title: Text("Report"), message: Text(reportMessage))
                            } else {
                                return Alert(
                                    title: Text("Are you sure?"),
                                    message: Text("Do you really want to report this post?"),
                                    primaryButton: .destructive(Text("Yes"), action: reportPost),
                                    secondaryButton: .cancel(Text("No"))
                                )
                            }
                        })
                    }
                    .padding()
                    .frame(width: metrics.size.width, height: 40, alignment: .leading)
        
                    Spacer(minLength: 10)
                    Divider()
                }
                Spacer(minLength: 100)
            }
            .frame(height: metrics.size.height + 100)
        }
        .onChange(of: post.image, perform: { value in
            initNewImage(image: value)
        })
        .animation(nil)
        .blur(radius: blurValue)
        .animation(.linear(duration: 0.4))
        .onReceive(timer, perform: { time in
            if blurValue == 10 {
                self.blurValue = 0
            } else {
                self.blurValue = 10
            }
        })
        .onChange(of: post.loading, perform: { value in
            if value ?? false {
                self.timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()
            } else {
                self.blurValue = 0
                self.timer.upstream.connect().cancel()
            }
        })
        .onAppear(perform: {
            if !(post.loading ?? false) {
                self.blurValue = 0
                self.timer.upstream.connect().cancel()
            }
            initNewImage(image: post.image)
        })
        .sheet(isPresented: $showingSheet) {
            ActivityView(activityItems: [NSURL(string: "https://www.quicpos.com/post/" + Helper.id)!] as [Any], applicationActivities: nil)
        }
    }
    
    func blockUser(){
        Network.shared.apollo
            .perform(mutation: BlockUserMutation(reqUser: userId, blockUser: post.userid ?? "", password: data.password)) { result in
                switch result {
                case .success(let graphQLResult):
                    if let blockConnection = graphQLResult.data?.blockUser {
                        if (blockConnection) {
                            self.blockAlertMessage = "Success, user blocked!"
                        } else {
                            self.blockAlertMessage = "Bad block return! Contact us to resolve the issue."
                        }
                    }
                    if let errors = graphQLResult.errors {
                        self.blockAlertMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                    }
                case .failure(let error):
                    self.blockAlertMessage = error.localizedDescription
                }
                self.blockAlert = true
                self.confirmationBlockAlert = true
            }
    }
    
    func reportPost(){
        if (post.ID != nil){
            let objectID = post.ID!.components(separatedBy: "\"")
            var id = ""
            if objectID.count == 1 {
                id = objectID[0]
            } else {
                id = objectID[1]
            }
            Network.shared.apollo
                .perform(mutation: ReportMutation(userID: userId, postID: id)) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let reportConnection = graphQLResult.data?.report {
                            if (reportConnection) {
                                self.reportMessage = "Thank you! Our team will review this post."
                            } else {
                                self.reportMessage = "Bad report return! Contact us to resolve the issue."
                            }
                        }
                        if let errors = graphQLResult.errors {
                            self.reportMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        }
                    case .failure(let error):
                        self.reportMessage = error.localizedDescription
                    }
                    self.reportAlertShow = true
                    self.reportConfirmationAlertShow = true
                }
        }
    }
    
    func reportShare(){
        var errorMessage = ""
        if (post.ID != nil){
            let objectID = post.ID!.components(separatedBy: "\"")
            var id = ""
            if objectID.count == 1 {
                id = objectID[0]
            } else {
                id = objectID[1]
            }
            
            Network.shared.apollo
                .perform(mutation: ShareMutation(userID: userId, postID: id, password: data.password)) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let shareConnection = graphQLResult.data?.share {
                            if (shareConnection) {
                                Helper.id = id
                                self.showingSheet = true
                                
                                var postids = UserDefaults.standard.stringArray(forKey: "myposts") ?? [String]()
                                if !postids.contains(id) {
                                    postids.append(id)
                                    UserDefaults.standard.set(postids, forKey: "myposts")
                                }
                            } else {
                                errorMessage = "Bad share report return! Contact us to resolve the issue."
                            }
                        }
                        if let errors = graphQLResult.errors {
                            errorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        }
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                    if (errorMessage != ""){
                        self.shareErrorMessage = errorMessage
                        self.shareAlertShow = true
                    }
                }
        }
    }
    
    func initNewImage(image: String?){
        if let im = image, im != "" {
            self.displayImage = true
            self.imageLoader = ImageLoader(urlString: "https://storage.googleapis.com/quicpos-images/" + image!)
        } else {
            self.displayImage = false
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(post: Post(text: "Post"), selectedMode: "NORMAL")
    }
}
