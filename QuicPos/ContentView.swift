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
    @State var post1 = Post(text: "Loading...")
    @State var post2 = Post(text: "")
    @State var firstOffset = CGSize(width: 0, height: 0)
    @State var opacityBG = 1.0
    @State var postReady = false
    @State var loading = true
    @State var scaleFG = CGFloat(1)
    @State var blurFG = CGFloat(0)
    @State var mode = "NORMAL"
    
    //DispatchGroup for async operations
    let group = DispatchGroup()
    
    var body: some View {
        
            NavigationView {
                GeometryReader { metrics in
                ZStack(){
                    Color.black
                    
                    
                    //mode button
                    Button(action: {
                        if mode == "NORMAL" {
                            self.mode = "PRIVATE"
                        } else {
                            self.mode = "NORMAL"
                        }
                    }, label: {
                        Text(mode)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.white)
                    }).offset(x: 0, y: -metrics.size.height/2 + 50)
                    
                    
                    //add button
                    NavigationLink(
                        destination: Creator(),
                        label: {
                            Image(systemName: "plus")
                            .font(.system(size: 27))
                            .foregroundColor(.white)
                        }).buttonStyle(PlainButtonStyle())
                        .offset(x: 0, y: metrics.size.height/2 - 50)
                    
                    
                    //background post
                    PostView(post: post2, metrics: metrics.size)
                        .scaleEffect(1.1)
                        .brightness(-0.08)
                        .blur(radius: 10)
                        .opacity(opacityBG)
                    

                    //foreground post
                    PostView(post: post1, metrics: metrics.size)
                        .scaleEffect(scaleFG)
                        .blur(radius: blurFG)
                        .offset(firstOffset)
                        .gesture(DragGesture()
                                    .onChanged { gesture in
                                        self.firstOffset = gesture.translation
                                    }
                                    .onEnded { _ in
                                        if getCGSizeLength(vector: self.firstOffset) > 100 {
                                            if postReady {
                                                self.scaleFG = 1.1
                                                self.blurFG = 10
                                                self.post1 = self.post2
                                                self.firstOffset = .zero
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
                                                    self.firstOffset = .zero
                                                }
                                            }
                                        } else {
                                            withAnimation(Animation.linear(duration: 0.1)){
                                                self.firstOffset = .zero
                                            }
                                        }
                                    })
                }
            }
            .onAppear(perform: {
                saveUserId()
                //group notify will run when enter() and leave() are balanced, waits for userId to be downloaded
                group.notify(queue: .main) {
                    getPost()
                    print(userId ?? "no user ID")
                }
            })
            .preferredColorScheme(.dark)
            .navigationBarHidden(true)
        }
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
                                self.post1 = Post(text: postConnection.text, image: postConnection.image)
                            } else {
                                self.post2 = Post(text: postConnection.text, image: postConnection.image)
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
