//
//  QuestionsFactory.swift
//  MathsTraining
//
//  Created by Alex Lopez on 29/11/2018.
//  Copyright © 2018 Cristian Lopez. All rights reserved.
//

import Foundation

class QuestionsFactory {
    
    private var questions = [Question]()
    private(set) var score: Int = 0
    private(set) var maxQuestions : Int = 5
    private(set) var pointsPerQuestion = 100
    
    init() {
        addNewQuestion()
    }
    
    func restartData() {
        self.score = 0
        self.questions.removeAll()
        addNewQuestion()
    }
    
    func addNewQuestion() {
        questions.insert(createQuestion(), at: 0)
    }
    
    func getQuestionAt(position: Int) -> Question? {
        if (position < 0 || position >= questions.count) {
            return nil
        }
        
        return self.questions[position]
    }
    
    func updateQuestion(at index: Int, wiht answer: Int) {
        questions[index].userAnswer = answer
    }
    
    func validateQuestion(at index: Int) {
        if self.questions[index].userAnswer == self.questions[index].answer {
            self.score += self.pointsPerQuestion
        }
    }
    
    func numberOfQuestions() -> Int {
        return questions.count
    }
    
    func createQuestion() -> Question {
        var question = ""
        var correctAnswer = 0
        
        while true {
            let firstNumber = Int.random(in: 0...9)
            let secondNumber = Int.random(in: 0...9)
            
            if Bool.random() {
                
                let result = firstNumber + secondNumber
                
                if result < 10 {
                    question = "\(firstNumber) + \(secondNumber)"
                    correctAnswer = result
                    break
                }
                
            } else {
                
                let result = firstNumber - secondNumber
                
                if result >= 0 {
                    question = "\(firstNumber) - \(secondNumber)"
                    correctAnswer = firstNumber - secondNumber
                    break
                }
            }
        }
        
        return Question(text: question, answer: correctAnswer, userAnswer: nil)
        
    }
}
