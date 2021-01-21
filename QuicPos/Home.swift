//
//  Home.swift
//  QuicPos
//
//  Created by kuba on 27/11/2020.
//

import SwiftUI

struct Home: View {
    
    @State var userId = UserDefaults.standard.string(forKey: "user") ?? ""
    @State var regulationsRead = UserDefaults.standard.bool(forKey: "regulations")
    @State var posts = [Post(text: "Loading...", loading: true), Post(text: "Loading...", loading: true)]
    @State var mode = "NORMAL"
    
    @State var timeAddition = UInt64(0)
    @State var startTime = DispatchTime.now()
    @State var viewError = ""
    @State var viewAlertShow = false
    @State var index = 0
    @State var deviceName = ""
    @State var adCounter = -2
    
    @State var showMyPosts = false
    @State var modeAlert = false
    @State var regulationsAlert = false
    @Environment(\.openURL) var openURL
    
    //DispatchGroup for async operations
    let group = DispatchGroup()
    
    var body: some View {
        VStack{
            //Post
            PostView(post: posts[index], selectedMode: mode)
            
            Spacer()
                .alert(isPresented: $regulationsAlert, content: {
                    Alert(
                        title: Text("Regulations"),
                        message: Text("By using QuicPos you agree to our regulations."),
                        primaryButton: .cancel(Text("Ok")),
                        secondaryButton: .default(Text("Read more")){
                            openURL(URL(string: "https://www.quicpos.com#regulations")!)
                        })
                })
            
            Spacer()
                .alert(isPresented: $viewAlertShow, content: {
                    Alert(title: Text("Error"), message: Text(viewError))
                })
            Spacer()
                .alert(isPresented: $modeAlert, content: {
                    if mode == "NORMAL"{
                        return Alert(title: Text("Mode change"), message: Text("Going to normal mode. Personalized content, user data collected."))
                    } else {
                        return Alert(title: Text("Mode change"), message: Text("Going to private mode. Random content, no user data collected."))
                    }
                })
        }
        .toolbar(content: {
            ToolbarItem(placement: .bottomBar){
                //back
                Button(action: {
                    prev()
                }, label: {
                    Image(systemName: "chevron.left")
                })
            }
            ToolbarItem(placement: .bottomBar){
                Spacer()
            }
            ToolbarItem(placement: .bottomBar){
                //next
                Button(action: {
                    next()
                }, label: {
                    Image(systemName: "chevron.right")
                })
            }
            ToolbarItem(placement: .bottomBar){
                if UIDevice.current.userInterfaceIdiom != .pad {
                    Spacer()
                } else {
                    EmptyView()
                }
            }
            ToolbarItem(placement: .bottomBar){
                if UIDevice.current.userInterfaceIdiom != .pad {
                    Button(action: {
                        self.showMyPosts = true
                    }, label: {
                        Image(systemName: "suit.heart")
                    })
                } else {
                    EmptyView()
                }
            }
            ToolbarItem(placement: .bottomBar){
                Spacer()
            }
            ToolbarItem(placement: .bottomBar){
                Button(action: {
                    if (self.mode == "NORMAL"){
                        self.mode = "PRIVATE"
                    } else {
                        self.mode = "NORMAL"
                    }
                    self.modeAlert = true
                }, label: {
                    if (self.mode == "NORMAL"){
                        Image(systemName: "shield")
                            .font(.system(size: 25))
                    } else {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 25))
                    }
                })
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            if index == posts.count-2{
                pauseTimer()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            resumeTimer()
        }
        .onAppear(perform: {
            saveUserId()
            regulations()
            //group notify will run when enter() and leave() are balanced, waits for userId to be downloaded
            group.notify(queue: .main) {
                getPost()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    getPost()
                }
            }
        })
        .navigationBarTitle(Text("QuicPos"), displayMode: .inline)
        .navigationBarItems(
            leading:
                NavigationLink(
                    destination: MyPosts(),
                    isActive: $showMyPosts,
                    label: {
                        Text("")
                    }),
            trailing:
                NavigationLink(
                    destination: Creator(),
                    label: {
                        Image(systemName: "square.and.pencil")
                    }))
    }
    
    func regulations() {
        if !regulationsRead {
            self.regulationsAlert = true
            UserDefaults.standard.setValue(true, forKey: "regulations")
            self.regulationsRead = true
        }
    }
    
    func prev() {
        if index>0 {
            if index == posts.count-2{
                pauseTimer()
            }
            self.index -= 1
        }
    }
    
    func next() {
        if index != posts.count-2 {
            self.index += 1
            if index == posts.count-2{
                resumeTimer()
            }
        }
        else {
            reportView()
            posts.append(Post(text: "Loading...", loading: true))
            if posts.count > 10 {
                posts.removeFirst()
            }
            getPost()
            self.index = posts.count-2
            startTimer()
        }
    }
    
    //APPLE DEVICE ID
    func machineName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    //DEVICE ID FOR MY SERVER
    func getDevice() -> String {
        if (deviceName == ""){
            self.deviceName = machineName()
        }
        return deviceName
    }
    
    func reportView(){
        let time = stopTimer()
        self.viewError = ""
        if (mode == "NORMAL"){
            if (userId != "" && posts[posts.count-2].ID != nil){
                let objectID = posts[posts.count-2].ID!.components(separatedBy: "\"")
                let data = AppValues()
                
                Network.shared.apollo
                    .perform(mutation: ViewMutation(userID: userId, postID: objectID[1], time: time, device: getDevice(), password: data.password)) { result in
                        switch result {
                        case .success(let graphQLResult):
                            if let viewConnection = graphQLResult.data?.view {
                                if !viewConnection {
                                    self.viewError = "Bad view report return!"
                                }
                            }
                            if let errors = graphQLResult.errors {
                                self.viewError = errors.map { $0.localizedDescription }.joined(separator: "\n")
                            }
                        case .failure(let error):
                            self.viewError = error.localizedDescription
                        }
                        if (viewError != ""){
                            self.viewAlertShow = true
                        }
                    }
            }
        }
    }
    
    func startTimer(){
        self.timeAddition = 0
        self.startTime = DispatchTime.now()
    }
    
    //returns elapsed time in seconds example 2.345123
    func stopTimer() -> Double {
        let elapsedTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds + timeAddition
        print(Double(elapsedTime) / 1_000_000_000)
        return Double(elapsedTime) / 1_000_000_000
    }
    
    func resumeTimer(){
        self.startTime = DispatchTime.now()
    }
    
    func pauseTimer(){
        self.timeAddition += DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
    }
    
    func getPost(){
        var normalMode = true
        if self.mode == "PRIVATE" {
            normalMode = false
        }
        let data = AppValues()
        var ad = false
        if adCounter % 20 == 0 {
            ad = true
        }
        
        Network.shared.apollo
            .fetch(query: GetPostQuery(userID: userId, normalMode: normalMode, password: data.password, ad: ad), cachePolicy: .fetchIgnoringCacheCompletely) { result in
                var index = posts.count-1
                if posts[posts.count-2].loading == true{
                    index = posts.count-2
                }
                switch result {
                case .success(let graphQLResult):
                    if let postConnection = graphQLResult.data?.post {
                        self.adCounter += 1
                        self.posts[index] = Post(
                            ID: postConnection.id,
                            text: postConnection.text,
                            userid: postConnection.userId,
                            image: postConnection.image,
                            shares: postConnection.shares,
                            views: postConnection.views,
                            creationTime: postConnection.creationTime,
                            ad: ad
                        )
                        if (index == posts.count-2){
                            startTimer()
                        }
                    }
                    if let errors = graphQLResult.errors {
                        self.posts[index] = Post(text: "Error: " + getDate() + "\n" + errors.map { $0.localizedDescription }.joined(separator: "\n") + "\n\nTap next post arrow to retry." )
                    }
                case .failure(let error):
                    self.posts[index] = Post(text: "Error: " + getDate() + "\n" + error.localizedDescription + "\n\nTap next post arrow to retry." )
                }
            }
    }
    
    func getDate() -> String{
        let today = Date()
        let formatter2 = DateFormatter()
        formatter2.timeStyle = .medium
        return formatter2.string(from: today)
    }
    
    func saveUserId(){
        if self.userId == ""{
            group.enter()
            //send this code to async
            DispatchQueue.main.async {
                let data = AppValues()
                
                //fetch and save data
                Network.shared.apollo
                    .fetch(query: GetUserQuery(password: data.password), cachePolicy: .fetchIgnoringCacheCompletely) { result in
                        switch result {
                        case .success(let graphQLResult):
                            if let userConnection = graphQLResult.data?.createUser {
                                UserDefaults.standard.setValue(userConnection, forKey: "user")
                                self.userId = userConnection
                            }
                            if let errors = graphQLResult.errors {
                                self.posts[posts.count-2] = Post(text: "Error: " + getDate() + "\n" + errors.map { $0.localizedDescription }.joined(separator: "\n") + "\n\nReset application to retry.")
                            }
                        case .failure(let error):
                            self.posts[posts.count-2] = Post(text: "Error: " + getDate() + "\n" + error.localizedDescription + "\n\nReset application to retry.")
                        }
                        //notify results are downloaded
                        group.leave()
                    }
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
