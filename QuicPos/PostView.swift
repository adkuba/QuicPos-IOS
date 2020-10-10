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
    var postReady: Bool
    var offsetValue: CGSize
    
    @State var timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()
    @State var blurValue = CGFloat(0)

    var body: some View {
        ZStack{
            Rectangle().frame(minWidth: metrics.width * 0.9, minHeight: 100, alignment: .center)
                .foregroundColor(Color(red: 50 / 255, green: 50 / 255, blue: 52 / 255))
                .cornerRadius(10)
            if postReady {
                Text(text).foregroundColor(Color.white)
                    .padding()
                    .frame(width: metrics.width * 0.85, height: 100, alignment: .leading)
            }
        }
        .fixedSize()
        .offset(offsetValue)
        .animation(.linear(duration: 0.1))
        .animation(nil)
        .blur(radius: blurValue)
        .animation(.linear(duration: 0.4))
        .onReceive(timer, perform: { time in
            if blurValue == 10 {
                self.blurValue = 0
            } else {
                self.blurValue = 10
            }
        })
        .onChange(of: postReady, perform: { value in
            if value {
                self.blurValue = 0
                self.timer.upstream.connect().cancel()
            } else {
                self.timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()
            }
        })
        .onAppear(perform: {
            if postReady {
                self.blurValue = 0
                self.timer.upstream.connect().cancel()
            }
        })
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(text: "Post", metrics: CGSize(width: 450, height: 1600), postReady: true, offsetValue: CGSize(width: 0, height: 0))
    }
}
