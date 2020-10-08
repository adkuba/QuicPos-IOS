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
    
    @State var showingAlert = false
    @State var errorMessage = ""
    @State var post1 = "Post 1"
    @State var post2 = "Post 2"
    @State var postReady = false
    @State var postError = "OK"
    @State var firstOffset = CGSize(width: 0, height: 0)
    @State var opacity = 1.0
    @State var mode = "NORMAL"
    
    //DispatchGroup for async operations
    let group = DispatchGroup()
    
    var body: some View {
        GeometryReader { metrics in
            ZStack(){
                Color.black
                
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
                
                
                //background post
                PostView(text: post2, metrics: metrics.size, postReady: true, postError: "OK")
                    .scaleEffect(1.1)
                    .brightness(-0.08)
                    .blur(radius: 10)

                //foreground post
                PostView(text: post1, metrics: metrics.size, postReady: postReady, postError: postError)
                    .offset(firstOffset)
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
                self.showingAlert = true
                print("alert showed")
            }
        })
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text("userId: "), message: Text(self.errorMessage), dismissButton: .default(Text("Got it!")))
        })
        .preferredColorScheme(.dark)
    }
    
    func getCGSizeLength(vector: CGSize) -> CGFloat {
        return sqrt(pow(vector.height, 2) + pow(vector.width, 2))
    }
    
    func getPost(initial: Bool = false){
        var normalMode = true
        if self.mode == "PRIVATE" {
            normalMode = false
        }
        //check if have userId
        saveUserId()
        group.notify(queue: .main) {
            Network.shared.apollo
                .fetch(query: GetPostQuery(userId: userId!, normalMode: normalMode), cachePolicy: .fetchIgnoringCacheCompletely) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let postConnection = graphQLResult.data?.post {
                            if initial {
                                self.post1 = postConnection.text
                            } else {
                                self.post2 = postConnection.text
                            }
                            self.postError = "OK"
                        }
                        if let errors = graphQLResult.errors {
                            self.postError = errors
                                .map { $0.localizedDescription }
                                .joined(separator: "\n")
                        }
                    case .failure(let error):
                        self.postError = error.localizedDescription
                    }
                }
            self.postReady = true
        }
    }
    
    func saveUserId(){
        if self.userId == nil{
            group.enter()
            //send this code to async
            DispatchQueue.main.async {
                //fetch and save data
                Network.shared.apollo
                    .fetch(query: GetUserQuery()) { result in
                        switch result {
                        case .success(let graphQLResult):
                            if let userConnection = graphQLResult.data?.createUser {
                                UserDefaults.standard.setValue(userConnection, forKey: "userId")
                                self.userId = userConnection
                                self.errorMessage = userConnection
                                print("userID saved")
                            }
                            if let errors = graphQLResult.errors {
                                self.errorMessage = errors
                                    .map { $0.localizedDescription }
                                    .joined(separator: "\n")
                            }
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                        }
                        //notify results are downloaded
                        group.leave()
                    }
            }
        } else {
            self.errorMessage = self.userId!
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
