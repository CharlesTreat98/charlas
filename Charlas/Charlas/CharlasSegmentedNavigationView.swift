import SwiftUI

struct CharlasSegmentedNavigationView: View {
    
    @State private var selectedSegment: Segment = .platicar
    
    var body: some View {
        VStack(spacing: 12.0) {
            SegmentContentContainer(selectedSegment: selectedSegment)
            
            Picker(
                "PickerSegmentView",
                selection: $selectedSegment,
                content: {
                    ForEach(Segment.allCases) { segment in
                        segment.image.tag(segment)
                    }
                },
            )
            .pickerStyle(.segmented)
        }
    }
}

private struct SegmentContentContainer: View {
    
    let selectedSegment: Segment
    
    var body: some View {
        switch selectedSegment {
        case .escenario:
            Text("No hay nada todavia")
        case .platicar:
            PlaticandoView()
        }
    }
}


private struct PlaticandoView: View {
    
    @State private var userEnteredText: String = ""
    
    var userEntries: [String] = [
        "Estoy aqui para beber unas trogas y bailar con mis amigos.",
        "Como piuedo mejorar mi capaz de hablar y escuchar sin intentar?"
    ]
    
    var body: some View {
        VStack {
            LazyVStack {
                ForEach(userEntries, id: \.self) { userText in
                    Text(userText)
                }
            }
            
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
    }
}

enum Segment: String, CaseIterable, Identifiable {
    
    case escenario
    case platicar
    
    var id: String {
        return rawValue
    }
    
    var image: Image {
        switch self {
        case .escenario:
            Image(systemName: "square.stack")
        case .platicar:
            Image(systemName: "sparkles")
        }
    }
}

#Preview {
    CharlasSegmentedNavigationView()
}
