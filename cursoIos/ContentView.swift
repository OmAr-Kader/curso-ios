//
//  ContentView.swift
//  cursoIos
//
//  Created by OmAr on 21/11/2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var app: AppModule

    var body: some View {
        NavigationStack {
           VStack {
               NavigationLink {
                   LoginScreen().environmentObject(app)
               } label: {
                   Image(systemName: "globe")
                       .imageScale(.large)
                       .foregroundStyle(.tint)
                   Text("Hello, world!")
               }
           }.padding()
        }
    }
}
