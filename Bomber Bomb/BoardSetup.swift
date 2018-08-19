//
//  BoardSetup.swift
//  Bomber Bomb
//
//  Created by Donald on 5/16/18.
//  Copyright © 2018 Donald. All rights reserved.
//

import SpriteKit

/* Basic set up of each level. Configurable every time a new level is loaded. */
struct Board {
    var rows: Int
    var columns: Int
    var grid: Int {
        return rows * columns
    }
    var mines: Int
    var level: Int
}

/* Each respective enum case is sent an an argument every time touch is detected. */
enum TouchType {
    case began, moved, ended, cancelled
}

/* This extension contains functions I wanted every scene to be able to make use of. Mostly comprises of touch handling and scene loading. */
extension SKScene {
    
    /**
     Loads the level selected.
     
     - Parameter transition: The transition used when the new scene is loaded (currently the same for each level)
     - Parameter bgColor: The level's background color.
     
     */
    func levelLoader(_ transition: SKTransition, _ bgColor: UIColor) {
        if let sweeper = Minesweeper(fileNamed: "Minesweeper") {
            sweeper.size = CGSize(width: screenWidth, height: screenHeight)
            sweeper.scaleMode = .resizeFill
            sweeper.backgroundColor = bgColor
            self.view?.presentScene(sweeper, transition: transition)
        }
    }
    
    /**
     Returns to the level select screen.
     
     - Parameter direction: Determines the direction the reveal transition will use.
     
     */
    func levelSelectLoader(direction: SKTransitionDirection) {
        if let select = LevelSelect(fileNamed: "LevelSelect") {
            select.size = CGSize(width: screenWidth, height: screenHeight)
            select.scaleMode = .aspectFill
            self.view?.presentScene(select, transition: SKTransition.reveal(with: direction, duration: 0.6))
        }
    }

    /**
     Determines where the user touched the screen and where the user touched the screen before, then it calls the "touchIdentifier" function to perform different actions depending on which type of touch this function received.
     
     - Parameter type: One of the touch types declared in the enum "TouchType".
     
     */
    func touchHandler(_ touches: Set<UITouch>, type: TouchType) {
        guard let touch = touches.first else {return}
        
        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        
        let nodeLocator = nodes(at: location)
        let previousNodeLocator = nodes(at: previousLocation)
        
        if nodeLocator != previousNodeLocator {
            for previousNode in previousNodeLocator {
                guard let nodeName = previousNode.name else {continue}
                
                if nodeName.hasPrefix("Level") && previousNode.frame.width != screenWidth {
                    previousNode.alpha = 0.2
                } else if self.isPaused && (nodeName == "Pause" || nodeName == "Resume") {
                    previousNode.alpha = 10
                } else {
                    previousNode.alpha = 1
                }
            }
        }
        
        /* nodeLocator is reversed because I usually want to evaluate the deepest nodes in the touch location first. */
        for node in nodeLocator.reversed() {
            if let nodeName = node.name {
                if !(self.isPaused) || nodeName == "Pause" || nodeName == "Resume" {
                    touchIdentifier(node, nodeName, touch: type, location)
                }
            }
        }
    }
    
    /**
     Changes node alpha values around to represent some semblance of touch resposiveness, then calls one of two functions to actually respond to the touch when it ends.
     
     - Parameter node: The node that is currently being identified.
     - Parameter name: The unwrapped name of said node.
     - Parameter touch: The type of touch.
     - Parameter location: The location of the touch. Unused in this function but necessary to pass to another function.
     
     */
    
    func touchIdentifier(_ node: SKNode, _ name: String, touch: TouchType, _ location: CGPoint) {
        guard name != "Frozen Tile" else {return}
        
        if touch != .ended {
            if touch == .cancelled {
                if name.hasPrefix("Level") && node.frame.width != screenWidth {
                    node.alpha = 0.2
                } else if self.isPaused && (name == "Pause" || name == "Resume") {
                    node.alpha = 10
                } else {
                    node.alpha = 1
                }
            } else if self.isPaused {
                node.alpha = 2.5
            } else {
                node.alpha = 0.5
            }
        } else {
            if name.hasPrefix("Level") && node.frame.width != screenWidth {
                node.alpha = 0.2
            } else if self.isPaused && (name == "Pause" || name == "Resume") {
                node.alpha = 10
            } else {
                node.alpha = 1
            }
            
            if !(self is Minesweeper) || name.hasPrefix("Level") {
                touchAction(name)
            } else {
                let currentScene = self as! Minesweeper
                let sprite = node as! SKSpriteNode
                currentScene.gameTouchAction(sprite, name, location)
            }
        }
    }

    /**
     Basically one giant switch statement to determine which node was touched and the actions to go with it. Does not deal with gameplay mechanics.
     
     - Parameter name: The unwrapped name of the node being evaluated.
     
     */
    func touchAction(_ name: String) {
        
    let transition = SKTransition.doorsOpenVertical(withDuration: 0.5)
        
        switch name {
            
        case "Load the level select screen":
            levelSelectLoader(direction: .left)
            
        case "Splash":
            if let backToStart = SplashScreen(fileNamed: "SplashScreen") {
                backToStart.size = CGSize(width: screenWidth, height: screenHeight)
                backToStart.scaleMode = .aspectFill
                self.view?.presentScene(backToStart, transition: SKTransition.reveal(with: .right, duration: 0.6))
            }
            
        case "Level 1":
            board = Board(rows: 6, columns: 6, mines: 5, level: 1)
            levelLoader(transition, .darkGray)
            
        case "Level 2":
            board = Board(rows: 6, columns: 7, mines: 6, level: 2)
            levelLoader(transition, UIColor(red: 0.33, green: 0.66, blue: 1, alpha: 1))
            
        case "Level 3":
            board = Board(rows: 7, columns: 7, mines: 7, level: 3)
            levelLoader(transition, .magenta)
            
        case "Level 4":
            board = Board(rows: 7, columns: 8, mines: 9, level: 4)
            levelLoader(transition, UIColor(red: 0.2, green: 0.66, blue: 0.2, alpha: 1))
            
        case "Level 5":
            board = Board(rows: 8, columns: 8, mines: 10, level: 5)
            levelLoader(transition, .brown)
            
        case "Level 6":
            board = Board(rows: 8, columns: 9, mines: 11, level: 6)
            levelLoader(transition, .orange)
            
        case "Level 7":
            board = Board(rows: 9, columns: 9, mines: 12, level: 7)
            levelLoader(transition, .blue)
            
        case "Level 8":
            board = Board(rows: 9, columns: 9, mines: 13, level: 8)
            levelLoader(transition, .gray)
            
        case "Level 9":
            board = Board(rows: 9, columns: 9, mines: 14, level: 9)
            levelLoader(transition, .green)
            
        case "Level 10":
            board = Board(rows: 10, columns: 10, mines: 16, level: 10)
            levelLoader(transition, .red)
            
        case "Level 11":
            board = Board(rows: 11, columns: 11, mines: 20, level: 11)
            levelLoader(transition, .purple)
            
        case "Level 12":
            board = Board(rows: 12, columns: 12, mines: 22, level: 12)
            levelLoader(transition, UIColor(red: 1, green: 0.66, blue: 0.33, alpha: 1))
            
        default:
            break
        }
    }
}
