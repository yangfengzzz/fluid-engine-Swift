//
//  ContentView.swift
//  vox.Force
//
//  Created by Feng Yang on 2020/7/23.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let renderer = Renderer()
    
    var body: some View {
        NavigationView {
            Button(action: {
                print("Button pressed!")
            }) {
                Text("Change Render Mode")
            }
            
            MetalKitView(view: renderer)
        }
        .frame(minWidth: 700, minHeight: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
