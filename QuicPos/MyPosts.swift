//
//  MyPosts.swift
//  QuicPos
//
//  Created by Kuba on 18/11/2020.
//

import SwiftUI

struct MyPosts: View {
    
    @State var postsids = UserDefaults.standard.stringArray(forKey: "myposts") ?? [String]()
    @State var userId = UserDefaults.standard.string(forKey: "user") ?? ""
    @State var posts: [Post] = []
    @State var postsNumber = 0
    
    @State var removeMessage = ""
    @State var removeAlert = false
    
    var body: some View {
        GeometryReader{ metrics in
            ScrollView{
                VStack{
                    if posts.count != 0 {
                        ForEach(posts, id: \.ID){ post in
                            if !(post.blocked ?? true) {
                                PostCard(post: post, metrics: metrics.size){
                                    postsids = postsids.filter{ $0 != post.ID }
                                    UserDefaults.standard.set(postsids, forKey: "myposts")
                                    self.removeMessage = "Your post has been deleted!"
                                    self.removeAlert = true
                                    postsNumber -= 1
                                    posts = posts.filter{ $0.ID != post.ID }
                                }
                            }
                        }
                        .alert(isPresented: $removeAlert, content: {
                            Alert(title: Text("Delete"), message: Text(removeMessage))
                        })
                    } else {
                        Spacer(minLength: 15)
                        Text("Share or create posts to save them.")
                            .padding()
                        Divider()
                    }
                }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .bottomBar){
                Spacer()
            }
            ToolbarItem(placement: .bottomBar){
                Text(String(postsNumber) + " posts")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            ToolbarItem(placement: .bottomBar){
                Spacer()
            }
        })
        .navigationBarTitle("Saved", displayMode: UIDevice.current.userInterfaceIdiom == .pad ? .automatic : .inline)
        .navigationBarItems(trailing:
                                NavigationLink(
                                    destination: Home(),
                                    label: {
                                        Image(systemName: "house")
                                })
                                .opacity(UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0))
        .onAppear(perform: {
            self.postsids = UserDefaults.standard.stringArray(forKey: "myposts") ?? [String]()
            self.postsNumber = postsids.count
            getPosts()
        })
    }
    
    func getPosts(){
        if userId != ""{
            posts.removeAll()
            let dispatchQueue = DispatchQueue(label: "mypostsget")
            let dispatchSemaphore = DispatchSemaphore(value: 0)
            
            dispatchQueue.async {
                var counter = 0
                postsids.forEach { postid in
                    Network.shared.apollo
                        .fetch(query: GetViewerPostQuery(id: postid)){ result in
                            switch result {
                            case .success(let graphQLResult):
                                if let postConnection = graphQLResult.data?.viewerPost {
                                    if postConnection.blocked == false && postConnection.text != "" {
                                        counter += 1
                                        self.posts.append(
                                            Post(
                                                ID: postid,
                                                text: postConnection.text,
                                                userid: postConnection.userId,
                                                image: postConnection.image,
                                                shares: postConnection.shares,
                                                views: postConnection.views,
                                                creationTime: postConnection.creationTime,
                                                blocked: postConnection.blocked
                                            ))
                                    }
                                }
                                if let errors = graphQLResult.errors {
                                    self.posts.append(
                                        Post(
                                            ID: UUID().uuidString,
                                            text: errors
                                            .map { $0.localizedDescription }
                                            .joined(separator: "\n")
                                        ))
                                }
                            case .failure(let error):
                                self.posts.append(
                                    Post(
                                        ID: UUID().uuidString,
                                        text: error.localizedDescription
                                    ))
                            }
                            dispatchSemaphore.signal()
                        }
                    dispatchSemaphore.wait()
                }
                self.postsNumber = counter
            }
        }
    }
}

struct MyPosts_Previews: PreviewProvider {
    static var previews: some View {
        MyPosts()
    }
}
