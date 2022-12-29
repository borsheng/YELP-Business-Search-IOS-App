//
//  SplashScreenView.swift
//  Business-ios
//
//  Created by Eric Huang on 2022/12/25.
//

import SwiftUI

struct SplashScreenView: View {
    
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var activesplash : Bool = false
    
    var body: some View {
        if activesplash{
            ContentView()
        }
        else{
            VStack{
                VStack{
                    Image("yelp_splash")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 128, height: 128)
//                    Text("YelpReviewApp")
//                        .font(.title)
//                        .foregroundColor(.black)
                    
                }// vstack
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear{
                    withAnimation(.easeIn(duration: 1.1)){
                        self.size = 0.9
                        self.opacity = 1.00
                    }
                }//appear
                
            }//vstack
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    withAnimation{
                        self.activesplash = true
                    }
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
