//
//  ContentView.swift
//  QuicPos
//
//  Created by Kuba on 03/10/2020.
//

import SwiftUI

struct AppValues {
    var password = "kuba"
}

struct ContentView: View {
    
    var body: some View {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            NavigationView{
                Home()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        case .pad:
            NavigationView{
                MyPosts()
                Home()
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        case .tv:
            Text("TV not supported")
        case .carPlay:
            Text("Car play unsupported!")
        case .mac:
            Text("Mac not supported!")
        case .unspecified:
            Text("Unspecified device!")
        @unknown default:
            Text("Unknown device!")
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
