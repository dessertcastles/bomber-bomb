//
//  LevelSelect.swift
//  Bomber Bomb
//
//  Created by Donald on 5/16/18.
//  Copyright © 2018 Donald. All rights reserved.
//

import SpriteKit

class LevelSelect: SKScene {
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let background = SKSpriteNode(imageNamed: "LevelSelectBackground")
        background.size = screenSize
        background.zPosition = -1
        addChild(background)
        
        var xLoop = 0
        var yLoop = 0
        
        var levelSelector: SKSpriteNode!
        
        for index in 1...12 {
            let shapeSize = CGSize(width: screenWidth / 5, height: screenWidth / 5)
            
            levelSelector = SKSpriteNode(color: .magenta, size: shapeSize)
            levelSelector.alpha = 0.2
            levelSelector.name = "Level \(index)"
            
            if index % 3 == 1 && index != 1 {
                yLoop += 1
                xLoop = 0
            }
            
            levelSelector.position.x = (-screenWidth / 3.2) + (levelSelector.size.width * CGFloat(xLoop) * 1.6)
            levelSelector.position.y = (screenHeight / 3.66) - (levelSelector.size.height * CGFloat(yLoop) * 1.6)
            
            let levelIndicator = SKLabelNode(fontNamed: "STHeitiTC-Light")
            levelIndicator.text = "\(index)"
            levelIndicator.position.x = levelSelector.position.x
            levelIndicator.position.y = levelSelector.position.y - (levelSelector.size.height / 4)
            levelIndicator.fontSize = levelSelector.size.height / 1.5
            levelIndicator.zPosition = 1
        
            addChild(levelSelector)
            addChild(levelIndicator)
            
            xLoop += 1
        }
        
        let backButton = SKSpriteNode(imageNamed: "BackButton")
        backButton.size.width = (screenWidth * 3) / 20
        backButton.size.height = backButton.size.width
        backButton.name = "Splash"
        backButton.position.x = -screenWidth / 2.6
        backButton.position.y = screenHeight / 2.4
        
        addChild(backButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchHandler(touches, type: .began)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchHandler(touches, type: .moved)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchHandler(touches, type: .ended)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchHandler(touches, type: .cancelled)
    }
}
