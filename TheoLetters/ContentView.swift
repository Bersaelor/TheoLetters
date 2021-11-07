//
//  ContentView.swift
//  TheoLetters
//
//  Created by Konrad Feiler on 07.11.21.
//

import AVFoundation
import SwiftUI

struct ContentView: View {

    enum FocusField: Hashable {
        case numbers
        case letters
    }

    @State private var currentLetter: String = "" {
        didSet {
            guard !currentLetter.isEmpty else { return }
            speak(currentLetter)
        }
    }
    @State private var textInput: String = ""
    @State private var inputMode: InputMode = .numbers
    @State private var language: Language = .en
    @FocusState private var focusedField: FocusField?

    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {

            ZStack {
                VStack {
                    HStack {
                        Picker("", selection: $inputMode) {
                            Text("123").tag(InputMode.numbers)
                            Text("ABC").tag(InputMode.letters)
                        }
                        .font(.title)
                        .foregroundColor(Color(.sRGB, red: 0.2, green: 0.8, blue: 0.0, opacity: 1.0))
                        .frame(height: 80)

                        Spacer()

                        Picker("", selection: $language) {
                            Text("🇬🇧").tag(Language.en)
                            Text("🇩🇪").tag(Language.de)
                        }
                        .foregroundColor(Color(.sRGB, red: 0.2, green: 0.8, blue: 0.0, opacity: 1.0))
                    }
                    .frame(height: 80)
                    .pickerStyle(.segmented)

                    Spacer()
                }

                VStack {
                    TextField("", text: $textInput, prompt: nil)
                        .focused($focusedField, equals: .letters)
                        .keyboardType(.alphabet)
                        .textFieldStyle(.roundedBorder)

                    TextField("", text: $textInput, prompt: nil)
                        .focused($focusedField, equals: .numbers)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                .disableAutocorrection(true)
                .opacity(0.0)

                Text(currentLetter)
                    .foregroundColor(.blue)
                    .font(.custom("", size: 120).weight(.black))
                    .frame(minWidth: 80, minHeight: 120)
                    .padding()
                    .background(Color.orange.opacity(0.5))
                    .cornerRadius(12.0)

            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {  /// Anything over 0.5 seems to work
                    focusedField = .numbers
                }
            }
            .onChange(of: inputMode) { newValue in
                if newValue == .numbers {
                    focusedField = .numbers
                } else {
                    focusedField = .letters
                }
            }
            .onChange(of: textInput) { newValue in
                withAnimation {
                    currentLetter = (newValue.last.flatMap { String($0) } ?? "").uppercased()
                }
            }
            .onChange(of: language) { newValue in
                if !currentLetter.isEmpty {
                    speak(currentLetter)
                }
            }
    }

    private func speak(_ string: String) {
        let utterance = AVSpeechUtterance(string: string.lowercased())
        utterance.voice = AVSpeechSynthesisVoice(language: language.code)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        print("uttering \(string)")
        synthesizer.speak(utterance)
    }

    enum InputMode {
        case numbers
        case letters
    }

    enum Language {
        case de
        case en

        var code: String {
            switch self {
            case .en:
                return "en-GB"
            case .de:
                return "de-DE"
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
