//
//  Minesweeper.swift
//  Bomber Bomb
//
//  Created by Donald on 5/4/18.
//  Copyright © 2018 Donald. All rights reserved.
//

import SpriteKit

var board = Board(rows: 6, columns: 6, mines: 5, level: 1)

class Minesweeper: SKScene {
    
    lazy var isGameOver = false
    lazy var flagModeOn = false
    lazy var firstTouch = true
    
    lazy var tilesRevealed = 0
    
    var tileArray = [SKSpriteNode]()
    var mineArray = [SKSpriteNode]()
    var questionMarkArray = [SKSpriteNode]()
    
    var flagArray = [SKSpriteNode]() {
        didSet {
            minesRemaining.text = "\(board.mines - flagArray.count)"
        }
    }
    
    var reveal: SKSpriteNode!
    var flagButton: SKSpriteNode!
    var pause: SKSpriteNode!
    
    var minesRemaining: SKLabelNode!
    
    var pauseLabel: SKLabelNode!
    var resume: SKSpriteNode!
    
    /* Array to compare the tile clicked to all adjacent tiles */
    let tileComparison = [-board.rows, board.rows, -1, -board.rows - 1, board.rows - 1, 1, board.rows + 1, -board.rows + 1, 0]
    
    lazy var numberCount = 0
    lazy var frozenTileCount = 0
    
    var emptyTiles = [Int]()
    
    /* This variable will be false when the tile touched has a question mark on it, and true otherwise. */
    lazy var wantsFlag = true
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let safeArea = view.safeAreaInsets
        
        var xLoop = 0
        var yLoop = 0
        
        /* Creates the tile grid at the start of the game */
        for index in 0..<board.grid {
            var tileSize: CGSize!
            
            if UIDevice.current.orientation.isPortrait {
                tileSize = CGSize(width: screenWidth / CGFloat(board.rows), height: screenWidth / CGFloat(board.rows))
            } else {
                tileSize = CGSize(width: screenHeight / CGFloat(board.rows), height: screenHeight / CGFloat(board.rows))
            }
            
            let tile = SKSpriteNode(color: .white, size: tileSize)
            
            tile.name = "Tile"
            
            if index % board.rows == 0 && index != 0 {
                yLoop += 1
                xLoop = 0
            }
            
            tile.position.x = (-screenWidth / 2) + (tile.size.width / 2) + (tile.size.width * CGFloat(xLoop))
            tile.position.y = ((screenHeight - safeArea.top) / 4) - (tile.size.height * CGFloat(yLoop))
            
            /* Creating the border of each tile. */
            let border = SKShapeNode(path: UIBezierPath(rect: tile.frame).cgPath)
            border.lineWidth = 2
            border.zPosition = 1
            border.strokeColor = .black
            
            tileArray.append(tile)
            addChild(tile)
            addChild(border)
            xLoop += 1
        }
        
        /* Tile freeze. The player can't click them and they don't know what's under them. */
        if board.level > 5 {
            let randomFreeze = randomization()
            
            for index in 0..<board.mines / 2 {
                tileArray[randomFreeze[index]].color = UIColor(red: 0, green: 0.6, blue: 1, alpha: 1)
                tileArray[randomFreeze[index]].name = "Frozen Tile"
                frozenTileCount += 1
            }
            
            tilesRevealed = frozenTileCount
        }
        
        var randomMines = randomization()
        randomMines.sort()
        print(randomMines)
        mineGenerator(randomMines)

        reveal = SKSpriteNode(imageNamed: "RevealButton")
        reveal.name = "Reveal"
        reveal.size.width = screenWidth / 2
        reveal.size.height = reveal.size.width * (231 / 587)
        reveal.position.x = -screenWidth / 4
        reveal.position.y = -screenHeight / 2 + reveal.size.height / 2
        
        flagButton = SKSpriteNode(imageNamed: "FlagButton")
        flagButton.name = "Flag Toggle"
        flagButton.size = reveal.size
        flagButton.position.x = screenWidth / 4
        flagButton.position.y = reveal.position.y
        
        pause = SKSpriteNode(imageNamed: "PauseButton")
        pause.name = "Pause"
        pause.size.width = screenWidth / 6
        pause.size.height = pause.size.width
        pause.position.x = screenWidth / 2 - pause.size.width
        pause.position.y = (((screenHeight - safeArea.top) / 2) + (tileArray[0].position.y + (tileArray[0].size.height / 2))) / 2
        
        minesRemaining = SKLabelNode(fontNamed: "Helvetica-Light")
        minesRemaining.text = "\(board.mines)"
        minesRemaining.fontSize = pause.size.height
        minesRemaining.position.x = -screenWidth / 6
        minesRemaining.position.y = pause.position.y - (pause.size.height * (3 / 8))
        minesRemaining.zPosition = 1
        
        let mine = SKSpriteNode(imageNamed: "Mine")
        mine.size = pause.size
        mine.position.x = -screenWidth / 2 + (mine.size.width * (5 / 8))
        mine.position.y = pause.position.y
        
        addChild(flagButton)
        addChild(reveal)
        addChild(pause)
        addChild(minesRemaining)
        addChild(mine)
    }
    
    /**
     Randomizes a non-repeating set of numbers equal to the amount of mines in play.
     To be improved with Swift 4.2 changes.
     
     - Returns: A randomized set of numbers which will represent the position of each mine in the game.
     */
    func randomization() -> [Int] {
        var nums = Array(0..<board.grid)
        var randoms = [Int]()
        
        for _ in 1...board.mines {
            let random = Int(arc4random_uniform(UInt32(nums.count)))
            randoms.append(nums[random])
            nums.remove(at: random)
        }
        
        return randoms
    }
    
    /**
     Generates the mines at the start of the game.
     
     - Parameter randoms: A randomized set of numbers which is used to position each mine in the game.
     */
    func mineGenerator(_ randoms: [Int]) {
        for index in 0..<board.mines {
            let mine = SKSpriteNode(color: UIColor(white: 1, alpha: 0), size: tileArray[0].size)
            
            mine.position = tileArray[randoms[index]].position
            mine.setScale(0.95)
            mine.zPosition = -1
            mine.name = "Mine"
            
            if tileArray[randoms[index]].name == "Frozen Tile" {
                mine.name = "Frozen Mine"
                tilesRevealed -= 1
            }
            
            if tileArray[randoms[index]].name == "Flagged Tile" {
                mine.name = "Flagged Mine"
            }
            
            mineArray.append(mine)
            
            tileArray[randoms[index]].name = "Bad Tile"
            
            addChild(mine)
        }
    }
    
    /**
     Checks if the adjacent tiles contain a bomb. This condition check would've been too long otherwise.
     Parameters are the variables declared in their respective loop.
     
     - Returns: A boolean saying whether the condition was met or not.
     */
    func bombChecker(_ comparison: Int, _ edgeCases: Int, _ index: Int) -> Bool {
        return tileArray[comparison].name == "Bad Tile" && ((index <= 1) || (index >= 2 && index <= 4 && edgeCases != 0) || (index >= 5 && index <= 7 && edgeCases != board.rows - 1))
    }
    
    /**
     Checks whether calculations go out of bounds in the array or within the tile grid itself. This condition check would've been too long otherwise.
     Parameters are the variables declared in their respective loop.
     
     - Returns: A boolean saying whether the condition was met or not.
     */
    func outOfBounds(_ adjacentComparison: Int, _ edgeCases: Int, _ index: Int) -> Bool {
        return adjacentComparison < 0 || adjacentComparison >= tileArray.count || (index >= 2 && index <= 4 && edgeCases == board.rows - 1) || (index >= 5 && index <= 7 && edgeCases == 0)
    }
    
    /**
     Shows the amount of mines surrounding the tile being evaluated.
     
     - Parameter tilePicker: The index of the "tileComparison" array to use for the comparison (0 - 8)
     - Parameter tileIndex: The position of the tile being compared in its array.
     */
    func numberMaker(_ tilePicker: Int = 8, tileIndex: Int) {
        let adjacentBombCount = SKSpriteNode(imageNamed: "#\(numberCount)")
        
        let comparisonPointer = tileArray[tileIndex + tileComparison[tilePicker]]
        
        if comparisonPointer.name != "Flagged Tile" && comparisonPointer.name != "Frozen Tile" {
        
            adjacentBombCount.position = comparisonPointer.position
            adjacentBombCount.size = tileArray[0].size
            adjacentBombCount.setScale(0.95)
            adjacentBombCount.zPosition = 1
            
            comparisonPointer.color = .gray
            comparisonPointer.name = "Revealed Tile"
            
            tilesRevealed += 1
            
            addChild(adjacentBombCount)
            
            if numberCount == 0 {
                let emptyTileIndex = tileIndex + tileComparison[tilePicker]
                emptyTiles.append(emptyTileIndex)
            }
        }
    }
    
    /**
     Checks all surrounding tiles when the tile touched had no surrounding mines.
     
     - Parameter tileIndex: The position of the tile being compared in its array.
     */
    func surroundingBombChecker(tileIndex: Int) {
        for index in 0...tileComparison.count - 2 {
            let adjacentComparison = tileIndex + tileComparison[index]
            let edgeCases = adjacentComparison % board.rows
            
            if outOfBounds(adjacentComparison, edgeCases, index) == false {
                if tileArray[adjacentComparison].name != "Revealed Tile" {
                    
                    for index2 in 0...tileComparison.count - 2 {
                        let comparison = adjacentComparison + tileComparison[index2]
                        if comparison >= 0 && comparison < tileArray.count {
                            if bombChecker(comparison, edgeCases, index2) {
                                numberCount += 1
                            }
                        }
                    }
                    
                    numberMaker(index, tileIndex: tileIndex)
                }
            }
            numberCount = 0
        }
    }
    
    /**
     The actions executed when the game is over.
     
     - Parameter location: The location of the touch.
     */
    func gameOver(_ location: CGPoint) {
        print("Game over")
        isGameOver = true
        
        for flag in flagArray {
            for tree in nodes(at: flag.position) {
                
                /* Checking whether the tile the player flagged contained a mine or not. */
                if tree.name == "Flagged Tile" {
                    let texture = SKSpriteNode(imageNamed: "WrongFlag")
                    texture.size = tree.frame.size
                    texture.position = tree.position
                    texture.zPosition = 3
                    addChild(texture)
                    
                    flag.removeFromParent()
                    
                } else if tree.name == "Flagged Mine" {
                    tree.removeFromParent()
                }
            }
        }
        
        for mine in mineArray {
            for tree in nodes(at: mine.position) {
                
                if tree.name == "Question" {
                    tree.removeFromParent()
                    break
                }
            }
            mine.texture = SKTexture(imageNamed: "Mine")
            mine.zPosition = 2
            mine.name = nil
        }
        
        for tree in nodes(at: location) {
            if tree.name == "Bad Tile" {
                tileArray[tileArray.index(of: tree as! SKSpriteNode)!].color = .red
                break
            }
        }
        
        reveal.removeFromParent()
        flagButton.removeFromParent()
        
        let tryAgain = SKSpriteNode(imageNamed: "TryAgain")
        tryAgain.name = "Try Again"
        tryAgain.size = reveal.size
        tryAgain.position = reveal.position
        addChild(tryAgain)
        
        let goBack = SKSpriteNode(imageNamed: "LevelSelectButton")
        goBack.name = "Return to the levels"
        goBack.size = flagButton.size
        goBack.position = flagButton.position
        addChild(goBack)
    }
    
    /**
     The actions executed when the level is deemed complete.
     */
    func levelComplete() {
        print("You win!")
        
        for question in questionMarkArray {
            question.removeFromParent()
        }
        
        mineLoop: for mine in mineArray {
            mine.name = nil
            
            for tree in nodes(at: mine.position).reversed() {
                if tree.name == "Flag" {
                    /* Breaks out of the inner loop and moves on to the next iteration of the outer loop. */
                    continue mineLoop
                } else if tree.name == "Tile" {
                    tree.name = nil
                }
            }
            
            flagMaker(flagPosition: mine.position)
        }
        
        reveal.removeFromParent()
        flagButton.removeFromParent()
        
        let nextLevel = SKSpriteNode(imageNamed: "NextLevel")
        nextLevel.name = "Level \(board.level + 1)"
        nextLevel.size.width = screenWidth
        nextLevel.size.height = nextLevel.size.width * (186 / 888)
        nextLevel.position.y = reveal.position.y
        addChild(nextLevel)
    }
    
    /**
     Creates a flag sprite.
     
     - Parameter spritePosition: The location in which I want the flag to be made.
     
     */
    func flagMaker(flagPosition spritePosition: CGPoint) {
        let flag = SKSpriteNode(imageNamed: "Flag")
        flag.size = tileArray[0].size
        flag.setScale(0.95)
        flag.position = spritePosition
        flag.zPosition = 1
        flag.name = "Flag"
        
        flagArray.append(flag)
        addChild(flag)
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
    
    /**
     Main game logic is here. Whenever the user finishes tapping on some location, the nodes at the location tapped are evaluated by their names starting with the deepest node first (lowest zPosition value).
     
     - Parameter sprite: The node being evaluated, successfully downcasted into an SKSpriteNode.
     - Parameter name: The unwrapped name of the sprite.
     - Parameter location: The location of the touch.
     
     */
    func gameTouchAction(_ sprite: SKSpriteNode, _ name: String, _ location: CGPoint) {
        switch name {
            
        case "Mine":
            if !firstTouch && !flagModeOn {
                gameOver(location)
                
            } else if firstTouch && !flagModeOn {
                
                var badTile: SKSpriteNode!
                
                /* Locating the tile that was tapped with a mine in it. */
                for tree in nodes(at: location) {
                    if tree.name == "Bad Tile" {
                        badTile = tileArray[tileArray.index(of: tree as! SKSpriteNode)!]
                        break
                    }
                }
                
                /* The name of the tile being evaluated will change when the mines are created again. */
                while badTile.name == "Bad Tile" {
                    for mine in mineArray {
                        mine.removeFromParent()
                    }
                    
                    for tile in tileArray {
                        if tile.name == "Bad Tile" {
                            tile.name = "Tile"
                        }
                    }
                    
                    mineArray.removeAll()
                    
                    tilesRevealed = frozenTileCount
                    
                    var randomMines = randomization()
                    randomMines.sort()
                    print(randomMines)
                    mineGenerator(randomMines)
                }
                
            } else if flagModeOn {
                for tree in nodes(at: location) {
                    if tree.name == "Question" {
                        wantsFlag = false
                        break
                    }
                }
                if wantsFlag {
                    flagMaker(flagPosition: sprite.position)
                    
                    sprite.name = "Flagged Mine"
                }
            }
            
        case "Tile":
            guard isGameOver == false else {return}
            
            if flagModeOn {
                for tree in nodes(at: location) {
                    if tree.name == "Question" {
                        wantsFlag = false
                        break
                    }
                }
                if wantsFlag {
                    flagMaker(flagPosition: sprite.position)
                    
                    sprite.name = "Flagged Tile"
                }
            } else {
                firstTouch = false
                
                numberCount = 0
                emptyTiles.removeAll()
                
                /* Have to ensure all tiles in the game are in this array. */
                guard let tileLocator = tileArray.index(of: sprite) else {
                    print("Tile not found.")
                    return
                }
                /* Checking all adjacent tiles to the tile tapped to check if they contain a mine. */
                for index in 0...tileComparison.count - 2 {
                    let comparison = tileLocator + tileComparison[index]
                    let edgeCases = tileLocator % board.rows   // Maintains calculations in bounds
                    if comparison >= 0 && comparison < tileArray.count  {   // Index out of bounds check
                        if bombChecker(comparison, edgeCases, index) {
                            numberCount += 1
                        }
                    }
                }
                
                numberMaker(tileIndex: tileLocator)
                
                if numberCount == 0 {
                    var tileTemp = 0
                    
                    surroundingBombChecker(tileIndex: tileLocator)

                    /* Keeps on revealing all tiles with no surrounding mines until it runs out of empty tiles to check. */
                    repeat {
                        tileTemp = emptyTiles.count
                        for empty in emptyTiles {
                            surroundingBombChecker(tileIndex: empty)
                        }
                    } while tileTemp != emptyTiles.count
                }
                
                if tilesRevealed == board.grid - board.mines {
                    levelComplete()
                }
            }
            
        case "Flag":
            if flagModeOn {
                let question = SKSpriteNode(imageNamed: "?")
                question.size = sprite.size
                question.name = "Question"
                question.position = sprite.position
                question.zPosition = 1
                
                sprite.removeFromParent()
                
                var containsMine = false
                
                for tree in nodes(at: location).reversed() {
                    if tree.name == "Flagged Mine" {
                        tree.name = "Mine"
                        containsMine = true
                    } else if tree.name == "Flagged Tile" {
                        if containsMine {
                            tree.name = "Bad Tile"
                        } else {
                            tree.name = "Tile"
                        }
                    }
                }
                
                flagArray.remove(at: flagArray.index(of: sprite)!)
                
                addChild(question)
                questionMarkArray.append(question)
            }
            
        case "Question":
            sprite.removeFromParent()
            questionMarkArray.remove(at: questionMarkArray.index(of: sprite)!)
            
            wantsFlag = true
            
        case "Try Again":
            levelLoader(SKTransition.doorsOpenVertical(withDuration: 0), backgroundColor)
            
        case "Return to the levels":
            levelSelectLoader(direction: .right)
            
        case "Reveal":
            flagModeOn = false
            print("No flagzzz")
            
        case "Flag Toggle":
            flagModeOn = true
            print("Flagzzz")
            
        case "Pause":
            if !isGameOver && self.isPaused == false {
                self.alpha = 0.2
                sprite.alpha = 10
                
                pauseLabel = SKLabelNode(fontNamed: "Helvetica-Neue")
                pauseLabel.alpha = 10
                pauseLabel.text = "Paused"
                pauseLabel.fontSize = 70
                pauseLabel.zPosition = 4
                addChild(pauseLabel)
                
                resume = SKSpriteNode(imageNamed: "Continue")
                resume.alpha = 10
                resume.name = "Resume"
                resume.size.width = screenWidth / 2
                resume.size.height = resume.size.width * (100 / 587)
                resume.position.y = -screenHeight / 12
                resume.zPosition = 4
                addChild(resume)
                
                self.isPaused = true
            }
            
        case "Resume":
            pauseLabel.removeFromParent()
            resume.removeFromParent()
            
            self.alpha = 1
            self.isPaused = false
            
        default:
            break
        }
    }
}
