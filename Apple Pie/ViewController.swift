//
//  ViewController.swift
//  Apple Pie
//
//  Created by Ulugbek Kahramonov on 6/11/24.
//

import UIKit
import SwiftUI


class ViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var treeImageView: UIImageView!
    @IBOutlet var correctWordLabel: UILabel!
    @IBOutlet var plusLabel: UILabel!
    @IBOutlet var letterButtons: [UIButton]!
    @IBOutlet var userWordTextField: UITextField!
    @IBOutlet var resetButton: UIBarButtonItem!

    let incorrectMovesAllowed = 6
    var currentGame: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userWordTextField.delegate = self
        defaultState()
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        for button in letterButtons {
            button.backgroundColor = UIColor.secondarySystemFill
        }
        resetButton.isEnabled = false
        defaultState()
    }
    
    func defaultState() {
        for button in letterButtons{
            button.isEnabled = false
        }
        userWordTextField.placeholder = "Type a word here."
        treeImageView.image = UIImage(named: "Hangman-0")
        currentGame = Game(word: "hangman", incorrectMovesRemaining: incorrectMovesAllowed, gameOver: false, guessedLetter: ["h","a", "n","g","m","a","n"])
        // get the word
        updateUI(defaultState: true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Call your function or execute your code here
        if textField.tag == 1 {
            if (userWordTextField.text == nil) {
                return false
            } else if userWordTextField.text!.count < 3 {
                userWordTextField.placeholder = "Too short."
            }
            else {
                newRound(word: userWordTextField.text!.lowercased())
                resetButton.isEnabled = true
                enableLetterButtons(true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.userWordTextField.placeholder = "Type a word here."
            }
        }
        
        // Dismiss the keyboard
        textField.text = ""
        textField.resignFirstResponder()
        
        // Return false to indicate that the text field should not process the return key
        return false
    }
    func updateUI(defaultState: Bool = false) {
        let letters = currentGame.formattedWord.map {String($0)}.joined(separator: " ")
        if !defaultState {
            treeImageView.image = UIImage(named: "Hangman-\(currentGame.incorrectMovesRemaining)")
        }
        correctWordLabel.text = letters
    }
    @IBAction func letterButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        let letterString = sender.configuration!.title!
        let letter = Character(letterString.lowercased())
        currentGame.playerGuessed(letter: letter)
        if currentGame.word.contains(letter) {
            let count = countInstances(of: letter, in: currentGame.word)
            showPlus(count: count)
            sender.layer.cornerRadius = 8
            sender.backgroundColor = .systemGreen
        } else {
            sender.layer.cornerRadius = 8
            sender.backgroundColor = UIColor.systemRed
        }
        updateGameState()
    }
    func newRound(word: String = "hangman") {
        // change buttons back to default state
        for button in letterButtons{
            button.layer.cornerRadius = 8
            button.backgroundColor = UIColor.secondarySystemFill
        }
        let gameWord = word.trimmingCharacters(in: .whitespaces)
        currentGame = Game(word: gameWord, incorrectMovesRemaining: incorrectMovesAllowed, gameOver: false, guessedLetter: [])
        // get the word
        updateUI()
    }
    func updateGameState() {
        if currentGame.incorrectMovesRemaining == 0 {
            gameLost()
            return
        } else if currentGame.word == currentGame.formattedWord {
            gameWon()
            return
        }
        updateUI()
        

    }
    func gameWon() {
        userWordTextField.placeholder = "You won!"
        currentGame.gameOver = true
        updateUI()
        enableLetterButtons(false)

    }
    func gameLost() {
        userWordTextField.placeholder = "You lost."
        currentGame.gameOver = true
        updateUI()
        enableLetterButtons(false)
        

    }
    
    func enableLetterButtons(_ state: Bool) {
        
        for letterButton in letterButtons {
            if letterButton.backgroundColor == UIColor.secondarySystemFill {
                letterButton.isEnabled = state
            }
        }
    }
    func showPlus(count: Int) {
        plusLabel.text = " +\(count)"
        plusLabel.textColor = .systemGreen
        enableLetterButtons(false)
        plusLabel.fadeIn(completion: {
            (finished: Bool) -> Void in
            self.plusLabel.fadeOut()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 4/7) {
            if !self.currentGame.gameOver {
                self.enableLetterButtons(true)
            }
        }
        
    }
    // count the amount of characters in a string
    func countInstances(of character: Character, in string: String) -> Int {
        var count = 0
        for char in string {
            if char == character {
                count += 1
            }
        }
        return count
    }
}

// fade in and out
extension UIView {


    func fadeIn(duration: TimeInterval = 0.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
        self.alpha = 1.0
        }, completion: completion)  }

    func fadeOut(duration: TimeInterval = 3/7, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            // Move the view slightly up and fade it out simultaneously
            self.alpha = 0.0
            self.transform = CGAffineTransform(translationX: 0, y: -20) // Adjust the value as needed for desired upward movement
        }, completion: { finished in
            // Once fade-out animation completes, reset the view's position
            UIView.animate(withDuration: duration, animations: {
                self.transform = .identity
            }, completion: completion)
        })
    }

}
