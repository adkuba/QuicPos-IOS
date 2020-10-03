//
//  ContentView.swift
//  QuicPos
//
//  Created by Kuba on 03/10/2020.
//

import SwiftUI

struct ContentView: View {
    
    //state allows modification during self invoke
    @State var postText = 1
    
    var body: some View {
        GeometryReader { metrics in
            ZStack{
                Color.black.ignoresSafeArea()
                Rectangle().frame(width: metrics.size.width * 0.85, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255))
                    .cornerRadius(10)
                    .gesture(TapGesture()
                                .onEnded({ _ in
                                    self.postText += 1
                                }))
                Text("Post " + String(self.postText))
                    .foregroundColor(Color.white)
                    .padding()
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
