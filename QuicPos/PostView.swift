//
//  PostView.swift
//  QuicPos
//
//  Created by Kuba on 06/10/2020.
//

import SwiftUI

struct PostView: View {
    
    var text: String
    var metrics: CGSize
    
    var body: some View {
        ZStack{
            Rectangle().frame(width: metrics.width * 0.9, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .foregroundColor(Color(red: 50 / 255, green: 50 / 255, blue: 52 / 255))
                .cornerRadius(10)
            Text(text).foregroundColor(Color.white)
                .padding()
        }
        .animation(.linear(duration: 0.1))
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(text: "Post", metrics: CGSize(width: 500, height: 1600))
    }
}
