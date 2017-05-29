//
//  Dialogue_Label.swift
//  App
//
//  Created by Kyle Tan on 5/18/17.
//  Copyright © 2017 Kyle Tan. All rights reserved.
//

import Foundation
import UIKit

class Dialogue_Label : UILabel{
    
    var timer = Timer()
    var isTimerRunning = false
    var curImageIndex = 0
    var stringToRender = ""
    var curStringIndex = 0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
        self.setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.setup()
    }
    
    func setup()
    {
        //add set up code here
    }
    
    func animate(newText: String, characterDelay: TimeInterval) {
        timer = Timer.scheduledTimer(timeInterval: characterDelay, target: self, selector: (#selector(Dialogue_Label.next_letter)), userInfo: nil, repeats: true)
        stringToRender = newText
        isTimerRunning = true
        /*DispatchQueue.main.async {
            
            self.text = ""
            
            for (index, character) in newText.characters.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay * Double(index)) {
                    self.text?.append(character)
                }
            }
        }*/
    }
    
    func next_letter()
    {
        if (curStringIndex >= stringToRender.characters.count)
        {
            curStringIndex = 0
            timer.invalidate()
            isTimerRunning = false
            return
        }
        //let i = advance(stringToRender.startIndex, curStringIndex)
        //let array = Array(stringToRender)
        let i = stringToRender.index(stringToRender.startIndex, offsetBy: curStringIndex)
        self.text?.append(stringToRender[i])
        curStringIndex+=1
        
    }
}
