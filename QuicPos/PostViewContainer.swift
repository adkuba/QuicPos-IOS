//
//  PostViewContainer.swift
//  QuicPos
//
//  Created by kuba on 26/11/2020.
//

import SwiftUI

struct PostViewContainer: View {
    
    let post: Post
    
    var body: some View {
        PostView(post: post, selectedMode: "NORMAL")
            .navigationBarTitle("Post", displayMode: .inline)
            .toolbar(content: {
                ToolbarItem(placement: .bottomBar){
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar){
                    Text(post.ID ?? "")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                ToolbarItem(placement: .bottomBar){
                    Spacer()
                }
            })
    }
}

struct PostViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        PostViewContainer(post: Post(text: "Post"))
    }
}
