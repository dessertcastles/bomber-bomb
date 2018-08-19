//
//  SplashScreen.swift
//  Bomber Bomb
//
//  Created by Donald on 5/4/18.
//  Copyright © 2018 Donald. All rights reserved.
//

import SpriteKit

class SplashScreen: SKScene {
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let background = SKSpriteNode(imageNamed: "SplashScreen")
        background.size = screenSize
        background.zPosition = -1
        
        let title = SKSpriteNode(imageNamed: "Title")
        title.size.width = screenWidth * (3 / 4)
        title.size.height = title.size.width * (65 / 617)
        title.position.y = screenHeight / 4
        
        let startButton = SKSpriteNode(imageNamed: "StartButton")
        startButton.name = "Load the level select screen"
        startButton.size.width = screenWidth / 1.5
        startButton.size.height = startButton.size.width * (302 / 772)
        startButton.position.y = -screenHeight / 6
        
        addChild(background)
        addChild(title)
        addChild(startButton)
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
