//
//  ContentView.swift
//  TorusDirectSDKDemo
//
//  Created by Shubham on 24/4/20.
//  Copyright © 2020 Shubham. All rights reserved.
//

import SwiftUI
import TorusSwiftDirectSDK
import FetchNodeDetails
import PromiseKit
import SafariServices
import web3swift
import CryptoSwift

struct ContentView: View {
    
    @State var showSafari = false
    
    var body: some View {
        NavigationView{
            List {
                Section(header: Text("Single Logins")) {
                    Group{
                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .wechat,
                                                         clientId: "cewDD3i6F1vtHeV1KIbaxUZ8vJQjJZ8V",
                                                         verifierName: "torus-auth0-wechat-lrc",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         jwtParams: ["domain":"torus-test.auth0.com"])
                            
                            let tdsdk = TorusSwiftDirectSDK(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-wechat-lrc", subVerifierDetails: [sub], loglevel: .trace)
                            tdsdk.triggerLogin(browserType: .external).done{ data in
                                print("private key rebuild", data)
                            }.catch{ err in
                                print(err)
                            }
                        }, label: {
                            Text("Wechat Login")
                        })
                        
                    }
                    
                    
                }
                
                Section(header: Text("Single ID verifier")){
                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .installed,
                                                     loginProvider: .google,
                                                     clientId: "238941746713-vfap8uumijal4ump28p9jd3lbe6onqt4.apps.googleusercontent.com",
                                                     verifierName: "google-ios",
                                                     redirectURL: "com.googleusercontent.apps.238941746713-vfap8uumijal4ump28p9jd3lbe6onqt4:/oauthredirect")
                        let tdsdk = TorusSwiftDirectSDK(aggregateVerifierType: .singleIdVerifier, aggregateVerifierName: "multigoogle-torus", subVerifierDetails: [sub])
                        tdsdk.triggerLogin(browserType: .external).done{ data in
                            print("private key rebuild", data)
                        }.catch{ err in
                            print(err)
                        }
                    }, label: {
                        Text("Google Login - Deep link flow")
                    })
                }
                
            }.navigationBarTitle(Text("DirectAuth app"))
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController
    
    var url: URL?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url!)
    }
    
    func updateUIViewController(_ safariViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
