//
//  ViewController.swift
//  MathsTraining
//
//  Created by Alex Lopez on 28/11/2018.
//  Copyright © 2018 Cristian Lopez. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var drawingView: DrawingImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    let factory = QuestionsFactory()
    var mnistModel = MnistModel()
    var gameTimer : Timer!
    var totalTime = 300
    var timeLeft : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawingView.delegate = self
        
        title = "Maths Training"
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 0.5
        
        self.restartGame(action: nil)
    }
    
    func numberDrawn(_ image: UIImage) {
        
        //Resize image for ML Model
        let modelSize = 299
        UIGraphicsBeginImageContextWithOptions(CGSize(width: modelSize, height: modelSize), true, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: modelSize, height: modelSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //UIImage -> CIImage
        guard let ciImage = CIImage(image: newImage) else {
            fatalError("Error in conversion")
        }
        
        //Load Model in Vision
        guard let model = try? VNCoreMLModel(for: mnistModel.model) else {
            fatalError("Error preparing Model in Vision")
        }
        
        //Call VNCoreMLRequest
        let request = VNCoreMLRequest(model: model) { [weak self] (request, error) in
            //Detect number drawn
            guard let results = request.results as? [VNClassificationObservation], let prediction = results.first else {
                fatalError("Error in prediction: \(error?.localizedDescription ?? "Unknown Error")")
            }
            
            DispatchQueue.main.async {
                let result = Int(prediction.identifier) ?? 0
                //Add answer user to actual question
                self?.factory.updateQuestion(at: 0, wiht: result)
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self?.factory.validateQuestion(at: 0)
                self?.askNextQuestion()
            }
            
        }
        
        //Add all to VNImageRequestHandler
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func askNextQuestion() {
        drawingView.image = nil
        
        if (self.timeLeft > 0) {
            print(timeLeft)
            factory.addNewQuestion()
            
            let newIndexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [newIndexPath], with: .right)
            
            let secondIndexPath = IndexPath(row: 1, section: 0)
            if let cell = tableView.cellForRow(at: secondIndexPath), let question = factory.getQuestionAt(position: 1) {
                setText(for: cell, at: secondIndexPath, to: question)
                
            }
        } else {
            print("end")
            gameTimer.invalidate()
            
            let controller = UIAlertController(title: "End of the match", message: "Score: \(self.factory.score)/\(self.factory.numberOfQuestions() * self.factory.pointsPerQuestion) points", preferredStyle: .alert)
            let action = UIAlertAction(title: "Play Again", style: .default, handler: restartGame)
            controller.addAction(action)
            present(controller, animated: true)
        }
        
    }

    func setText(for cell: UITableViewCell, at indexPath: IndexPath, to question: Question) {
        if indexPath.row == 0 {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 36)
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
            
            if question.answer == question.userAnswer {
                cell.backgroundColor = UIColor(red: 0.3, green: 1.0, blue: 0.3, alpha: 0.25)
            } else {
                cell.backgroundColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.25)
            }
        }
        
        if let userAnswer = question.userAnswer {
            cell.textLabel?.text = "\(question.text) = \(userAnswer)"
        } else {
            cell.textLabel?.text = "\(question.text) = ?"
        }
    }
    
    // - MARK: UITableViewDataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return factory.numberOfQuestions()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let currentQuestion = factory.getQuestionAt(position: indexPath.row) {
            setText(for: cell, at: indexPath, to: currentQuestion)
        }
        return cell
    }
    
    // - MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func restartGame(action: UIAlertAction?) {
        
        factory.restartData()
        self.tableView.reloadData()
        
        self.timeLeft = self.totalTime
        
        self.progressView.progress = 1.0
        self.progressView.progressTintColor = UIColor.green
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            self.timeLeft -= 1
            self.progressView.progress = Float(max(self.timeLeft, 0)) / Float(self.totalTime)
            
            let greenvalue = CGFloat(Float(self.timeLeft)/Float(self.totalTime))
            let redValue = 1.0 - greenvalue
            
            self.progressView.progressTintColor = UIColor(red: redValue, green: greenvalue, blue: 0, alpha: 1.0)
        })
    }
}

