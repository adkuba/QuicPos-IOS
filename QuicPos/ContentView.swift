//
//  ContentView.swift
//  QuicPos
//
//  Created by Kuba on 03/10/2020.
//

import SwiftUI

struct ContentView: View {
    
    //state allows modification during self invoke
    @State var userId = UserDefaults.standard.integer(forKey: "userId")
    @State var posts = [Post(text: "Loading...", loading: true), Post(text: "Loading...", loading: true)]
    @State var mode = "NORMAL"
    
    @State var timeAddition = UInt64(0)
    @State var startTime = DispatchTime.now()
    @State var viewError = ""
    @State var viewAlertShow = false
    @State var index = 0
    
    //DispatchGroup for async operations
    let group = DispatchGroup()
    
    var body: some View {
        NavigationView {
            GeometryReader { metrics in
                VStack{
                    //Post
                    PostView(post: posts[index], metrics: metrics.size, selectedMode: mode)
                }
            }
            .toolbar(content: {
                ToolbarItemGroup(placement: .bottomBar){
                    //back
                    Button(action: {
                        prev()
                    }, label: {
                        Image(systemName: "chevron.left")
                    })
                    Button(action: {
                        prev()
                    }, label: {
                        Text("Prev")
                    })
                    
                }
                ToolbarItem(placement: .bottomBar){
                    Spacer()
                        //alert from view!
                        .alert(isPresented: $viewAlertShow, content: {
                            Alert(title: Text("Error"), message: Text(viewError))
                        })
                }
                ToolbarItemGroup(placement: .bottomBar){
                    //next
                    Button(action: {
                        next()
                    }, label: {
                        Text("Next")
                    })
                    Button(action: {
                        next()
                    }, label: {
                        Image(systemName: "chevron.right")
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
                        destination: Creator(),
                        label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                        }),
                trailing:
                    Button(action: {
                        if (self.mode == "NORMAL"){
                            self.mode = "PRIVATE"
                        } else {
                            self.mode = "NORMAL"
                        }
                    }, label: {
                        if (self.mode == "NORMAL"){
                            Image(systemName: "shield")
                                .font(.system(size: 25))
                        } else {
                            Image(systemName: "lock.shield")
                                .font(.system(size: 25))
                        }
                    }))
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
                
                Network.shared.apollo
                    .perform(mutation: ViewMutation(userID: userId, postID: objectID[1], time: stopTimer(), device: getDevice())) { result in
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
        Network.shared.apollo
            .fetch(query: GetPostQuery(userID: userId, normalMode: normalMode), cachePolicy: .fetchIgnoringCacheCompletely) { result in
                var index = posts.count-1
                if posts[posts.count-2].ID == nil{
                    index = posts.count-2
                }
                switch result {
                case .success(let graphQLResult):
                    if let postConnection = graphQLResult.data?.post {
                        self.posts[index] = Post(
                            ID: postConnection.id,
                            text: postConnection.text,
                            image: postConnection.image,
                            shares: postConnection.shares,
                            views: postConnection.views,
                            creationTime: postConnection.creationTime
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
                //fetch and save data
                Network.shared.apollo
                    .fetch(query: GetUserQuery(), cachePolicy: .fetchIgnoringCacheCompletely) { result in
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
