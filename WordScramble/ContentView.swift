//
//  ContentView.swift
//  WordScramble
//
//  Created by Joel Martinez on 9/12/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    private enum Field: Int, Hashable {
        case newWord
    }

    @FocusState private var focusedTextField: Field?
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter a word...", text: $newWord)
                        .autocapitalization(.none)
                        .focused($focusedTextField, equals: .newWord)
                }
                Section("Score: \(score)") {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar(content: {
                Button("Next word", action: startGame)
            })
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {  }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard ![answer].contains(rootWord) else {
            wordError(title: "Word is the root word", message: "You can't get credit for typing the same word.")
            return
        }
        
        guard isTooShort(word: answer) else {
            wordError(title: "Word is to short", message: "It has to be at least three letters long.")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word was used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You cannot spell that word from \(rootWord)")
            return
        }
        
        guard isWordReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            newWord = ""
        }
        
        score += answer.count
        focusedTextField = .newWord
    }
    
    func startGame() {
        guard let wordfile = Bundle.main.url(forResource: "start", withExtension: "txt"), let string = try? String(contentsOf: wordfile) else {
            fatalError("Could not read words from start.txt")
        }
        
        let words = string.components(separatedBy: "\n")
        rootWord = words.randomElement() ?? "silkworm"
        score = 0
        usedWords = [String]()
    }
    
    //too short
    func isTooShort(word: String) -> Bool {
        !(word.count < 3)
    }
    
    //original
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    //posible
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    //does the word exist
    func isWordReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
