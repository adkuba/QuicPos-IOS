//
//  ContentView.swift
//  QuicPos
//
//  Created by Kuba on 03/10/2020.
//

import SwiftUI

struct ContentView: View {
    
    //state allows modification during self invoke
    @State var userId = UserDefaults.standard.string(forKey: "userId")
    @State var post1 = Post(text: "Loading...", loading: true)
    @State var post2 = Post(text: "")
    @State var firstOffset = CGSize(width: 0, height: -15)
    @State var opacityBG = 1.0
    @State var postReady = false
    @State var loading = true
    @State var scaleFG = CGFloat(1)
    @State var blurFG = CGFloat(0)
    @State var mode = "NORMAL"
    
    @State var timeAddition = UInt64(0)
    @State var startTime = DispatchTime.now()
    @State var viewError = ""
    @State var viewAlertShow = false
    
    //DispatchGroup for async operations
    let group = DispatchGroup()
    
    var body: some View {
        
        NavigationView {
            GeometryReader { metrics in
                ZStack(){
                    Color.black
                    
                    //add button
                    NavigationLink(
                        destination: Creator(),
                        label: {
                            HStack{
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Text("Create")
                                    .fontWeight(.semibold)
                            }
                        })
                        .offset(x: 0, y: metrics.size.height/2 - 30)
                    
                    
                    //background post
                    PostView(post: post2, metrics: metrics.size, selectedMode: mode)
                        .scaleEffect(1.1)
                        .brightness(-0.08)
                        .blur(radius: 10)
                        .opacity(opacityBG)
                        .offset(x: 0, y: -10)
                    

                    //foreground post
                    PostView(post: post1, metrics: metrics.size, selectedMode: mode)
                        .scaleEffect(scaleFG)
                        .blur(radius: blurFG)
                        .offset(firstOffset)
                        .gesture(DragGesture()
                                    .onChanged { gesture in
                                        self.firstOffset = CGSize(
                                            width: gesture.translation.width,
                                            height: gesture.translation.height - 15)
                                    }
                                    .onEnded { _ in
                                        if getCGSizeLength(vector: self.firstOffset) > 100 {
                                            if postReady {
                                                self.scaleFG = 1.1
                                                self.blurFG = 10
                                                reportView()
                                                self.post1 = self.post2
                                                startTimer()
                                                self.firstOffset = CGSize(width: 0, height: -15)
                                                withAnimation(Animation.easeInOut(duration: 0.2)){
                                                    self.blurFG = 0
                                                    self.scaleFG = 1
                                                }
                                                self.postReady = false
                                                self.opacityBG = 0
                                                getPost()
                                            } else {
                                                self.post1 = Post(text: "Loading...", loading: true)
                                                self.loading = true
                                                withAnimation(Animation.linear(duration: 0.1)){
                                                    self.firstOffset = CGSize(width: 0, height: -15)
                                                }
                                            }
                                        } else {
                                            withAnimation(Animation.linear(duration: 0.1)){
                                                self.firstOffset = CGSize(width: 0, height: -15)
                                            }
                                        }
                                    })
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                pauseTimer()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                resumeTimer()
            }
            .alert(isPresented: $viewAlertShow, content: {
                Alert(title: Text("Error"), message: Text(viewError))
            })
            .onAppear(perform: {
                saveUserId()
                //group notify will run when enter() and leave() are balanced, waits for userId to be downloaded
                group.notify(queue: .main) {
                    getPost()
                    print(userId ?? "no user ID")
                }
            })
            .preferredColorScheme(.dark)
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(
                leading:
                    Text("QuicPos")
                        .fontWeight(.semibold),
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
    
    func machineName() -> String {
      var systemInfo = utsname()
      uname(&systemInfo)
      let machineMirror = Mirror(reflecting: systemInfo.machine)
      return machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
      }
    }
    
    func reportView(){
        if (mode == "NORMAL"){
            if (userId != nil && post1.ID != nil){
                let objectID = post1.ID!.components(separatedBy: "\"")
                Network.shared.apollo
                    .perform(mutation: ViewMutation(userID: userId!, postID: objectID[1], time: stopTimer(), device: "Apple " + machineName())) { result in
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
        return Double(elapsedTime) / 1_000_000_000
    }
    
    func resumeTimer(){
        self.startTime = DispatchTime.now()
    }
    
    func pauseTimer(){
        self.timeAddition += DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
    }
    
    func getCGSizeLength(vector: CGSize) -> CGFloat {
        return sqrt(pow(vector.height, 2) + pow(vector.width, 2))
    }
    
    func getPost(initial: Bool = false){
        var normalMode = true
        if self.mode == "PRIVATE" {
            normalMode = false
        }
        //check userId in case of initial run failed
        saveUserId()
        group.notify(queue: .main) {
            Network.shared.apollo
                .fetch(query: GetPostQuery(userId: userId!, normalMode: normalMode), cachePolicy: .fetchIgnoringCacheCompletely) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let postConnection = graphQLResult.data?.post {
                            if loading {
                                self.post1 = Post(
                                    ID: postConnection.id,
                                    text: postConnection.text,
                                    image: postConnection.image,
                                    shares: postConnection.shares,
                                    views: postConnection.views,
                                    creationTime: postConnection.creationTime
                                )
                                startTimer()
                            } else {
                                self.post2 = Post(
                                    ID: postConnection.id,
                                    text: postConnection.text,
                                    image: postConnection.image,
                                    shares: postConnection.shares,
                                    views: postConnection.views,
                                    creationTime: postConnection.creationTime
                                )
                                self.post1.nextImage = postConnection.image
                                withAnimation(Animation.easeInOut(duration: 0.4).delay(0.4)){
                                    self.opacityBG = 1
                                }
                            }
                        }
                        if let errors = graphQLResult.errors {
                            if loading {
                                self.post1 = Post(text: errors
                                                    .map { $0.localizedDescription }
                                                    .joined(separator: "\n"))
                            } else {
                                self.post2 = Post(text: errors
                                                    .map { $0.localizedDescription }
                                                    .joined(separator: "\n"))
                            }
                        }
                    case .failure(let error):
                        if loading {
                            self.post1 = Post(text: error.localizedDescription)
                        } else {
                            self.post2 = Post(text: error.localizedDescription)
                        }
                    }
                    if loading {
                        self.loading = false
                        getPost()
                    } else {
                        self.postReady = true
                    }
                }
        }
    }
    
    func saveUserId(){
        if self.userId == nil{
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
                                self.post1 = Post(text: errors
                                                    .map { $0.localizedDescription }
                                                    .joined(separator: "\n"))
                            }
                        case .failure(let error):
                            self.post1 = Post(text: error.localizedDescription)
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
