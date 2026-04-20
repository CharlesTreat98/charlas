//
//  ContentView.swift
//  Charlas
//
//  Created by Charles Treat on 4/3/26.
//

import SwiftUI
import FoundationModels
import Speech

struct ContentView: View {
    
    @State
    var userEnteredText: String = ""
    
    var body: some View {
        VStack {
            TextField(text: $userEnteredText, label: {
                Text("Toque aqui")
            })
            .textFieldStyle(.roundedBorder)
            .background{
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(.thinMaterial)
            }
            .padding(.bottom, 8)
            DictationButton(text: $userEnteredText, title: "Dictate")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
