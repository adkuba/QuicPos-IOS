//
//  Home.swift
//  QuicPos
//
//  Created by kuba on 27/11/2020.
//

import SwiftUI

struct Home: View {
    
    //state allows modification during self invoke
    @State var userId = UserDefaults.standard.integer(forKey: "userId")
    @State var posts = [Post(text: "Loading...", loading: true), Post(text: "Loading...", loading: true)]
    @State var mode = "NORMAL"
    
    @State var timeAddition = UInt64(0)
    @State var startTime = DispatchTime.now()
    @State var viewError = ""
    @State var viewAlertShow = false
    @State var index = 0
    @State var adCounter = -2
    
    @State var showMyPosts = false
    @State var modeAlert = false
    
    //DispatchGroup for async operations
    let group = DispatchGroup()
    
    var body: some View {
        VStack{
            //Post
            PostView(post: posts[index], selectedMode: mode)
            
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
            pauseTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            resumeTimer()
        }
        .onAppear(perform: {
            saveUserId()
            //group notify will run when enter() and leave() are balanced, waits for userId to be downloaded
            group.notify(queue: .main) {
                getPost()
                getPost()
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
        else if posts[posts.count-2].ID != nil {
            reportView()
            posts.append(Post(text: "Loading...", loading: true))
            if posts.count > 10 {
                posts.removeFirst()
            }
            getPost()
            self.index = posts.count-2
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
    func getDevice() -> Int {
        let deviceString = machineName()
        var device = 100000
        if (deviceString.contains("iPhone")){
            device += 1000
        } else if (deviceString.contains("iPad")){
            device += 2000
        }
        var multiplication = 1
        for ch in deviceString {
            let value = Int(String(ch)) ?? 0
            if value != 0 {
                device += value * multiplication
                multiplication *= 10
            }
        }
        return device
    }
    
    func reportView(){
        if (mode == "NORMAL"){
            if (userId != 0 && posts[posts.count-2].ID != nil){
                let objectID = posts[posts.count-2].ID!.components(separatedBy: "\"")
                let data = AppValues()
                
                Network.shared.apollo
                    .perform(mutation: ViewMutation(userID: userId, postID: objectID[1], time: stopTimer(), device: getDevice(), password: data.password)) { result in
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
            } else {
                self.viewError = "No userID or postID!"
                self.viewAlertShow = true
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
                if posts[posts.count-2].ID == nil{
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
                        startTimer()
                    }
                    if let errors = graphQLResult.errors {
                        self.posts[index] = Post(text: errors
                                                            .map { $0.localizedDescription }
                                                            .joined(separator: "\n"))
                    }
                case .failure(let error):
                    self.posts[index] = Post(text: error.localizedDescription)
                }
            }
    }
    
    func saveUserId(){
        if self.userId == 0{
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
                                UserDefaults.standard.setValue(userConnection, forKey: "userId")
                                self.userId = userConnection
                            }
                            if let errors = graphQLResult.errors {
                                self.posts[posts.count-2] = Post(text: errors
                                                    .map { $0.localizedDescription }
                                                    .joined(separator: "\n"))
                            }
                        case .failure(let error):
                            self.posts[posts.count-2] = Post(text: error.localizedDescription)
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
