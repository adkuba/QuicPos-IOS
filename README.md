# Table of contents
- [What I've learned](#what-ive-learned)
- [SwiftUI](#swiftui)
  - [About](#about)
  - [More](#more)
- [Application](#application)
- [Apollo](#apollo)
  - [Usage](#usage)



# What I've learned
- How to create client application in **SwiftUI** for **iPhone** and **iPad**
- Working with **Apollo GraphQL**
- Deploying application to **App Store**
- Using pure **Swift**



# SwiftUI
### About
SwiftUI is the newer wersion of Swift. It offers better integration of UI and code. It is the future of development for all Apple platforms. Right now SwiftUI is in the early state so knowledge of pure Swift methods for UI is and probably always will be very useful. [More info](https://fuckingswiftui.com)
- <code>QuicPosApp.swift</code> is like in SpringBoot main function that starts app
- [About async wait functions](https://stackoverflow.com/questions/42484281/waiting-until-the-task-finishes/42484670), example <code>DispatchGroup</code> for async operations.
- <code>@State</code> allows variable modification when invoking with <code>self.variable_name</code>



### More
SwiftUI works like views on forntend (example Vue) - seperate pages. Views can also be components - we can re-use them multiple times. We can modify this views with attributes just like for example css. To switch between pages use NavigationView or TabView. 
- [Tutorial](https://developer.apple.com/tutorials/swiftui/composing-complex-interfaces)



# Application
Application notes:
- I've created 2 seperate looks for iPad and iPhone. Mainly conditional components - see for example <code>ContentView.swift</code> file.
- Create <code>AppValues.swift</code> file with struct and general password variable!
- <code>LinkedText.swift</code> [source](https://gist.github.com/mjm/0581781f85db45b05e8e2c5c33696f88) and my modification.



# XCode
XCode important notes:
- Sometimes you need to log in again to Apple account: <code>Xcode -> Preference -> Accounts</code>
- Bug with slow application start on the devide re simulator. Delete folders in: <code>/Users/kuba/Library/Developer/Xcode</code> and relaunch XCode.



# Apollo
Apollo - package to use GraphQL in Swift. [Tutorial](https://www.apollographql.com/docs/ios/tutorial/tutorial-obtain-schema/)
### Usage
To download schema form server uncomment last line and comment first line. First line builds methods, <code>API.swift</code> file, from donloaded schema. This it part of the file in: <code>project settings - target - build phases - apollo CLI</code>
```sh
"${SCRIPT_PATH}"/run-bundled-codegen.sh codegen:generate --target=swift --includes=./**/*.graphql --localSchemaFile="schema.json" API.swift
#"${SCRIPT_PATH}"/run-bundled-codegen.sh schema:download --endpoint="http://192.168.8.106:8080/query"
```

First download then generate! Only <code>API.swift</code> and <code>Network.swift</code> must be included to the app package. Seperate <code>.graphql</code> files are not included in the package, but they contain the graphql definition of needed endpoint. See API documentation in server [repository](https://github.com/adkuba/QuicPos-Server).