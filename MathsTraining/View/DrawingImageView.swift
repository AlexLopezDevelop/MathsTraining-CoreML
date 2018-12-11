//
//  DrawingImageView.swift
//  MathsTraining
//
//  Created by Alex Lopez on 28/11/2018.
//  Copyright © 2018 Cristian Lopez. All rights reserved.
//

import UIKit

class DrawingImageView: UIImageView {

    weak var delegate : ViewController?
    var currentTouchPosition: CGPoint?
    
    func draw(from start: CGPoint, to end: CGPoint) {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        self.image = renderer.image { context in
            self.image?.draw(in: self.bounds)
            
            //Parametros cgContext
            UIColor.darkGray.setStroke()
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineWidth(12)
            
            //Draw line
            context.cgContext.move(to: start)
            context.cgContext.addLine(to: end)
            context.cgContext.strokePath()
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.currentTouchPosition = touches.first?.location(in: self)
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let newTouchPoint = touches.first?.location(in: self) else {
            return
        }
        
        guard let previousTouchPoint = self.currentTouchPosition else {
            return
        }
        
        draw(from: previousTouchPoint, to: newTouchPoint)
        self.currentTouchPosition = newTouchPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.currentTouchPosition = nil
        
        perform(#selector(numberDrawnOnScreen), with: nil, afterDelay: 0.5)
    }
    
    @objc func numberDrawnOnScreen() {
        guard let image = self.image else {
            return
        }
        
        let drawRect = CGRect(x: 0, y: 0, width: 28, height: 28)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(bounds: drawRect, format: format)
        
        let imageWithWhiteBackground = renderer.image { context in
            UIColor.white.setFill()
            context.fill(bounds)
            image.draw(in: drawRect)
        }
        
        //UIImage from CG to CI
        let ciImage = CIImage(cgImage: imageWithWhiteBackground.cgImage!)
        
        //Conversion color white to black
        if let filter = CIFilter(name: "CIColorInvert") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            let context = CIContext(options: nil)
            
            if let outputImage = filter.outputImage {
                if let imageRef = context.createCGImage(outputImage, from: ciImage.extent) {
                    
                    let resultImage = UIImage(cgImage: imageRef)
                    self.delegate?.numberDrawn(resultImage)
                    
                }
            }
        }
    }
}
