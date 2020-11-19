//
//  MyPosts.swift
//  QuicPos
//
//  Created by Kuba on 18/11/2020.
//

import SwiftUI

struct MyPosts: View {
    
    @State var posts = [Post(ID: "5eft35she625d", text: "Sample post1"), Post(ID: "id2", text: "Sample post2")]
    
    var body: some View {
        GeometryReader{ metrics in
            ScrollView{
                VStack{
                    ForEach(posts, id: \.ID){ post in
                        PostCard(post: post, metrics: metrics.size)
                    }
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
