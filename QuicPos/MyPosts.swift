//
//  MyPosts.swift
//  QuicPos
//
//  Created by Kuba on 18/11/2020.
//

import SwiftUI

struct MyPosts: View {
    
    @State var postsids = UserDefaults.standard.stringArray(forKey: "myposts") ?? [String]()
    @State var userId = UserDefaults.standard.integer(forKey: "userId")
    @State var posts: [Post] = []
    
    var body: some View {
        GeometryReader{ metrics in
            ScrollView{
                VStack{
                    if posts.count != 0 {
                        ForEach(posts, id: \.ID){ post in
                            if !(post.blocked ?? true) {
                                PostCard(post: post, metrics: metrics.size)
                            }
                        }
                    } else {
                        Spacer(minLength: 15)
                        Text("Share or create posts to save them.")
                            .padding()
                        Divider()
                    }
                }
            }
        }
        .onAppear(perform: {
            self.postsids = UserDefaults.standard.stringArray(forKey: "myposts") ?? [String]()
            getPosts()
        })
    }
    
    func getPosts(){
        if userId != 0{
            posts.removeAll()
            let dispatchQueue = DispatchQueue(label: "mypostsget")
            let dispatchSemaphore = DispatchSemaphore(value: 0)
            
            dispatchQueue.async {
                postsids.forEach { postid in
                    Network.shared.apollo
                        .fetch(query: GetViewerPostQuery(id: postid)){ result in
                            switch result {
                            case .success(let graphQLResult):
                                if let postConnection = graphQLResult.data?.viewerPost {
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
            }
        }
    }
}

struct MyPosts_Previews: PreviewProvider {
    static var previews: some View {
        MyPosts()
    }
}
