 //
 //  MenuScreen.swift
 //  SpaceRace
 //
 //  Created by Cade Conklin on 4/4/17.
 //  Copyright © 2017 Cade Conklin. All rights reserved.
 //
 
 //
 //  GameScene.swift
 //  SpaceRace
 //
 //  Created by Cade Conklin on 3/15/17.
 //  Copyright © 2017 Cade Conklin. All rights reserved.
 //
 
 import SpriteKit
 import GameplayKit
 import UIKit
 import AVKit
 import AVFoundation
 
 class HelpScene: SKScene , SKPhysicsContactDelegate{
    var background:SKSpriteNode!
    
    var screenSize = UIScreen.main.bounds
    var location:CGPoint!
    var touchesCounter = 1 {
        didSet {
            background = SKSpriteNode(imageNamed: "help\(touchesCounter)")
        }
    }
    
    
    
    override func didMove(to view: SKView) {
        touchesCounter = 1
        
        background = SKSpriteNode(imageNamed: "help1")
        background.position = CGPoint(x: 0 + screenSize.width, y: 0 + screenSize.height)
        background.zPosition = -1
        self.addChild(background)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    
    
    
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            
            self.touchDown(atPoint: t.location(in: self))
            location = t.location(in: self)
            if location.x < screenSize.width && touchesCounter == 1 || location.x > screenSize.width && touchesCounter == 5{
                let transition = SKTransition.reveal(with: .down, duration: 1.0)
                
                let nextScene = GameScene(size: scene!.size)
                nextScene.scaleMode = .aspectFill
                
                scene?.view?.presentScene(nextScene, transition: transition)
            }
            if location.x > screenSize.width && touchesCounter >= 1 && touchesCounter < 5{
                background.removeFromParent()
                touchesCounter += 1
                background.position = CGPoint(x: 0 + screenSize.width, y: 0 + screenSize.height)
                background.zPosition = -1
                self.addChild(background)
            }
            if location.x < screenSize.width && touchesCounter > 1 && touchesCounter <= 5{
                background.removeFromParent()
                touchesCounter -= 1
                background.position = CGPoint(x: 0 + screenSize.width, y: 0 + screenSize.height)
                background.zPosition = -1
                self.addChild(background)
            }
            
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch : AnyObject in touches {
            location = touch.location(in: self)
            
        }
        for t in touches { self.touchMoved(toPoint: t.location(in: self))
            
        }
    }
    
    
    
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
 }

