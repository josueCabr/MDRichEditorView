//
//  ContentView.swift
//  Shared
//
//  Created by Josue Cabrera on 2022-07-27.
//

import SwiftUI
import MDRichEditor

struct ContentView: View {
    @State private var showVC = false
    
    var body: some View {
        VStack {
            Button("Present"){
                showVC = true
            }
        }
        .sheet(isPresented: $showVC) {
            ListView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ListView()
        }
    }
}

struct ListView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> EditorViewController {
        return EditorViewController()
    }
    
    func updateUIViewController(_ uiViewController: EditorViewController, context: Context) {
        
    }
}
