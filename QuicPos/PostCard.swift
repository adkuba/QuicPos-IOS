//
//  PostCard.swift
//  QuicPos
//
//  Created by Kuba on 18/11/2020.
//

import SwiftUI

struct PostCard: View {
    
    var post: Post
    var metrics: CGSize
    
    var body: some View {
        VStack{
            Spacer(minLength: 30)
            NavigationLink(
                destination: PostView(post: post, metrics: metrics, selectedMode: "NORMAL"),
                label: {
                    VStack{
                        Text(post.text)
                            .frame(width: metrics.width * 0.9, height: 17, alignment: .leading)
                            .foregroundColor(.primary)
                        Text((post.ID ?? "postid"))
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .frame(width: metrics.width * 0.9, height: 17, alignment: .leading)
                            .padding()
                    }
                    
                })
            Divider()
        }
        .navigationBarTitle("Saved", displayMode: .inline)
    }
}

struct PostCard_Previews: PreviewProvider {
    static var previews: some View {
        PostCard(post: Post(text: "Post"), metrics: CGSize(width: 450, height: 1600))
    }
}
