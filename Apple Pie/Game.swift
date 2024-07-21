//
//  Game.swift
//  Apple Pie
//
//  Created by Ulugbek Kahramonov on 6/11/24.
//

import Foundation

struct Game {
    var word: String
    var incorrectMovesRemaining: Int
    var gameOver: Bool
    var guessedLetter: [Character]
    var formattedWord: String {
        var guessedWord = ""
        for letter in word {
            if guessedLetter.contains(letter) || letter == " " {
                guessedWord += "\(letter)"
            } else {
                guessedWord += "_"
            }
        }
        return guessedWord
    }
    
    mutating func playerGuessed(letter: Character) {
        guessedLetter.append(letter)
        if !word.contains(letter) {
            incorrectMovesRemaining -= 1
        }
    }
}
