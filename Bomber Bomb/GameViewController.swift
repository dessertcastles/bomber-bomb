//
//  GameViewController.swift
//  Bomber Bomb
//
//  Created by Donald on 5/4/18.
//  Copyright © 2018 Donald. All rights reserved.
//

import UIKit
import SpriteKit

let screenWidth = UIScreen.main.bounds.width // Gets the screen resolution
let screenHeight = UIScreen.main.bounds.height
let screenSize = UIScreen.main.bounds.size

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loads the splash screen
        if let scene = SplashScreen(fileNamed: "SplashScreen") {
            
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true

            scene.size = screenSize
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
