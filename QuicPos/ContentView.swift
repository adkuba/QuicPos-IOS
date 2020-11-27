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
        NavigationView {
            /*
             Stworzyć osobnego brancha z tych commitów - to będzie wersja na iPada
             Bo jak przerobiłem na iPada to wszystko się rozjebało na iPhona
             */
             
            if UIDevice.current.userInterfaceIdiom == .pad {
                MyPosts()
            }
            
            Home()
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
