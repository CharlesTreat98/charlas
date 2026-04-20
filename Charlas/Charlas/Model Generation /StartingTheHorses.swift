import Foundation
import FoundationModels

enum StartingTheHorses {
    
    @MainActor
    static func start() async throws {
        let session = LanguageModelSession(instructions: freeFormEntryInstructions)
        try await session.respond(prompt: {
            // Where some user settings can be used to change the initial input 
            freeFormInitialPrompt
        })
    }
    
    // Should we inject the CEFR level
    static let freeFormEntryInstructions = """
            You are going to be acting as a spanish tutor who will be responding to an intermediate to advanced spansish learner, providing an improvised practice session using back and forth dialogue in spanish.  
            The vocab and grammar should be appropriate for a student at the high B2 - low C1 level on the CEFR international scale.
        
            Each time the user responds to you, analyze their response for any gramatical errors and then generate a conversational response. 
        """
    
    static let freeFormInitialPrompt = Prompt {
        """
            Start the conversation with the student by asking an initial question. The question should be conversational and positive. 
        """
    }
}

protocol FreeFormSettings {
}

@Generable
struct CharlaEntry {
    
    let spanishResponse: String
    
    @Guide(description: "Itemized list of mistakes the speaker made while speaking.")
    let grammarCorrections: [String]
}

struct PredefinedScenario: Sendable {
    
    let scenarioName: LocalizedStringResource
    let scenarioInstructions: String
}
