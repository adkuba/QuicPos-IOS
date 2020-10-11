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
    @State var post1 = Post(text: "")
    @State var post2 = Post(text: "")
    @State var postReady = false
    @State var firstOffset = CGSize(width: 0, height: 0)
    @State var opacity = 1.0
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
                    PostView(post: post2, metrics: metrics.size, postReady: true, offsetValue: CGSize(width: 0, height: 0))
                        .scaleEffect(1.1)
                        .brightness(-0.08)
                        .blur(radius: 10)
                    

                    //foreground post
                    PostView(post: post1, metrics: metrics.size, postReady: postReady, offsetValue: firstOffset)
                        .opacity(opacity)
                        .gesture(DragGesture()
                                    .onChanged { gesture in
                                        self.firstOffset = gesture.translation
                                    }
                                    .onEnded { _ in
                                        if getCGSizeLength(vector: self.firstOffset) > 100 && postReady {
                                            self.opacity = 0
                                            withAnimation(.easeInOut(duration: 0.5)){
                                                self.post1 = self.post2
                                                self.opacity = 1
                                            }
                                            self.postReady = false
                                            getPost()
                                        }
                                        self.firstOffset = .zero
                                    })
                }
            }
            .onAppear(perform: {
                saveUserId()
                //group notify will run when enter() and leave() are balanced, waits for userId to be downloaded
                group.notify(queue: .main) {
                    getPost(initial: true)
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
                            if initial {
                                self.post1 = Post(text: postConnection.text)
                            } else {
                                self.post2 = Post(text: postConnection.text)
                            }
                        }
                        if let errors = graphQLResult.errors {
                            self.post1 = Post(text: errors
                                                .map { $0.localizedDescription }
                                                .joined(separator: "\n"))
                        }
                    case .failure(let error):
                        self.post1 = Post(text: error.localizedDescription)
                    }
                    self.postReady = true
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
