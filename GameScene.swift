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

class MenuScene: SKScene , SKPhysicsContactDelegate{
    //sprites and emitters
    private var sparkNode : SKEmitterNode?
    var background:SKSpriteNode!
    var follower:SKSpriteNode!
    var pad:SKSpriteNode!
    var ball:SKSpriteNode!
    var spaceship:SKSpriteNode!
    var restartButton:SKSpriteNode!
    var heart:SKSpriteNode!
    var bombExplosion:SKSpriteNode!
    
    //buttons
    var bomb:UIButton!
    var pauseButton:UIButton!
    var resumeButton:UIButton!
    var soundButton:UIButton!
    var quitButton:UIButton!
    
    //arrays of sprites
    var aliens = [SKSpriteNode]()
    var torpedos = [SKSpriteNode]()
    
    //asteroid stuff
    var asteroids = [SKSpriteNode]()
    var asteroidXvelo = [CGFloat]()
    var asteroidYvelo = [CGFloat]()
    var asteroidNumber = 0
    var alienRand = [Int]()
    var alienDead = [Bool]()
    var alienNumber:Int = 0
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var highScoreLabel = SKLabelNode()
    var highscore = 0
    
    //alien stuff
    var aliensHit:Int = 0
    var alienStart:Int = 0
    var maxAliens:Int = 0
    
    //Time is relative
    var timer:Timer!
    var asteroidTimer:Timer!
    var alienTimer:Timer!
    var torpedoTimer:Timer!
    var heartTimer:Timer!
    var bombTimer:Timer!
    var seconds:TimeInterval!
    var seconds2:TimeInterval!
    
    //screen stuff
    var screenSize = UIScreen.main.bounds
    var location:CGPoint!
    
    //physics categories
    var asteroidCategory:UInt32 = 0x1 << 1
    var photonTorpedoCategory:UInt32 = 0x1 << 0
    var spaceshipCategory:UInt32 = 0x1 << 2
    var alienCategory:UInt32 = 0x1 << 3
    var heartCategory:UInt32 = 0x1 << 4
    var bombCategory:UInt32 = 0x1 << 5
    var princeCategory:UInt32 = 0x1 << 6
    
    //labels
    var scoreLabel:SKLabelNode!
    var healthLabel:SKLabelNode!
    var princeHealthLabel:SKLabelNode!
    
    //delta and such
    var xJoystickDelta = CGFloat()
    var yJoystickDelta = CGFloat()
    var maxxJoystickDelta = CGFloat()
    var maxyJoystickDelta = CGFloat()
    var xAlienDelta = [CGFloat]()
    var yAlienDelta = [CGFloat]()
    var AlienDelta = [CGFloat]()

    //music and bools
    var bgMusic:AVAudioPlayer!
    var musicPlayed:Bool!
    var exploding:Bool!

    //the one hitbox
    var spaceshipHitBox:SKSpriteNode!
    
    //health set text label every time health is set
    var health = 0 {
        didSet {
            healthLabel.text = "Health: \(health)"
        }
    }
    
    //keep count of the wave
    var wave = 1
    var counter = 1
    
    //bools and hearts
    var gameOver = false
    var gamePaused = false
    var princeOn = false
    var heartsOnScreen = 0
    
    //quotes and people
    //used for end game
    var quotes: [String] = ["You miss all the shots you don't take.", "I like palm trees.", "I like the sound of my own voice.", "Rome? I thought we were going to Italy!", "I can acutely smell peanut butter.", "Be prepared!", "Too bad you're ugly.", "You hear about Pluto? That's messed up right?", "As if.", "Nothing in life is promised except death.", "Take my advice–I'm not using it.", "Real G's move in silence like lasagna.", "The best part about me is I am not you.", "I use unmelted butter on my popcorn.", "The dot on an I is a tittle.", "Warm milk is the best milk.", "My hands smell like hands." , "Pizza slices are meant to be eaten crust first.", "Your first love is your last second of innocence.", "Work will make you free." , "Team Team Team Team", "Whom's mans?", "Leave it all to me.", "Sometimes you're the raindrop.", "It's easier without a fork.", "Banana Sauce is superior to Apple Sauce.", "Chew your food thoroughly before you swallow."]
    var people: [String] = ["-Lebron James", "-Barack Obama", "-Whoopi Goldberg", "-Lindsey Lohan", "-Kanye West", "-Christine Teigen", "-Carrot Top", "-Bono", "-Steve Carrell", "-Tim Tebow", "-George Washington", "-Mr. T", "-Missy Elliott", "-Gandhi", "-Yo-Yo Ma", "-Miranda Cosgrove", "-Derek Jeter", "-Justin Trudeau", "-Justin Bieber", "-Ryan Gosling", "-Kendrick Lamar", "-Michael Jackson", "-Nelson Mandela", "-Abraham Lincoln", "-Donald Trump", "-The Shins","-Vince Vaughn"]
    var quoteLabel = SKLabelNode()
    var peopleLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        //intialize variables aka set them up
      initialize()
        
        //timers that are global and don't change
        self.timer = Timer.scheduledTimer(timeInterval: 0.045, target: self, selector: #selector(update(_:)), userInfo: nil, repeats: true)
        self.torpedoTimer = Timer.scheduledTimer(timeInterval: 1.1, target: self, selector: #selector(alienTorpedoFire), userInfo: nil, repeats: true)
        self.heartTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(addHeart), userInfo: nil, repeats: true)
        
    }

    

    
    
    
    
    
    
    func initialize() {
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        let musicRandom = Int(arc4random() % UInt32(3) + 1)
        
        let bgMusicURL:NSURL = Bundle.main.url(forResource: "music\(musicRandom)", withExtension: "wav" )! as NSURL
        do { bgMusic = try AVAudioPlayer(contentsOf: bgMusicURL as URL, fileTypeHint: nil) }
        catch _{
            return print("no music file")
        }
        musicPlayed = true
        
        quoteLabel = SKLabelNode(text: "")
        quoteLabel.position = CGPoint(x: screenSize.width, y: screenSize.height)
        quoteLabel.fontName = "AmericanTypewriter-Bold"
        quoteLabel.fontSize = 30
        quoteLabel.fontColor = UIColor.white
        
        peopleLabel = SKLabelNode(text: "")
        peopleLabel.position = CGPoint(x: screenSize.width, y: screenSize.height / 2)
        peopleLabel.fontName = "AmericanTypewriter-Bold"
        peopleLabel.fontSize = 30
        peopleLabel.fontColor = UIColor.white
        
        bgMusic.numberOfLoops = -1
        bgMusic.prepareToPlay()
        bgMusic.play()
        
        pad = SKSpriteNode(imageNamed: "joystickback2")
        pad.size = CGSize(width: (screenSize.width * 2) / 2.5, height: screenSize.height / 2.5)
        pad.position = CGPoint(x: pad.size.width / 2, y: (pad.frame.height / 2) + pad.frame.size.height / 3)
        
        restartButton = SKSpriteNode(imageNamed: "replay")
        restartButton.position = CGPoint(x: screenSize.width, y: (screenSize.height / 4) * 3)
        
        ball = SKSpriteNode(imageNamed: "joystickfront2")
        ball.size = CGSize(width: (screenSize.width * 2) / 5, height: screenSize.height / 5)
        ball.position = CGPoint(x: pad.position.x, y: pad.position.y)
        
        follower = SKSpriteNode(imageNamed: "star")
        follower.position = CGPoint(x: follower.size.width / 2, y: follower.frame.height / 2)
        follower.zPosition = -2
        self.addChild(follower)
        
        spaceship = SKSpriteNode(imageNamed: "ship3")
        spaceship.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.addChild(spaceship)
        
        spaceshipHitBox = SKSpriteNode(imageNamed: "star")
        spaceshipHitBox.position = CGPoint(x: spaceship.position.x, y: spaceship.position.y)
        spaceshipHitBox.size = CGSize(width: spaceship.size.width / 2, height: spaceship.size.height / 2)
        spaceshipHitBox.physicsBody = SKPhysicsBody(rectangleOf: spaceshipHitBox.size)
        spaceshipHitBox.zPosition = -2
        spaceshipHitBox.physicsBody?.isDynamic = true
        spaceshipHitBox.physicsBody?.categoryBitMask = spaceshipCategory
        spaceshipHitBox.physicsBody?.contactTestBitMask = asteroidCategory | photonTorpedoCategory | heartCategory
        spaceshipHitBox.physicsBody?.collisionBitMask = asteroidCategory | photonTorpedoCategory | heartCategory
        self.addChild(spaceshipHitBox)
        
        background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0 + screenSize.width, y: 0 + screenSize.height)
        background.zPosition = -1
        self.addChild(background)
        
        bombExplosion = SKSpriteNode(imageNamed: "pad")
        bombExplosion.position = spaceship.position
        bombExplosion.size = CGSize(width: spaceship.size.width, height: spaceship.size.height)
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 100, y: self.frame.size.height - 60)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        self.addChild(scoreLabel)
        
        healthLabel = SKLabelNode(text: "Health: 20")
        healthLabel.position = CGPoint(x: self.frame.size.width - 100, y: self.frame.size.height - 60)
        healthLabel.fontName = "AmericanTypewriter-Bold"
        healthLabel.fontSize = 36
        healthLabel.fontColor = UIColor.white
        self.addChild(healthLabel)
        
        princeHealthLabel = SKLabelNode(text: "Prince: 20")
        princeHealthLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 60)
        princeHealthLabel.fontName = "AmericanTypewriter-Bold"
        princeHealthLabel.fontSize = 36
        princeHealthLabel.fontColor = UIColor.white
        
        pauseButton = UIButton(frame: CGRect(x: screenSize.width - 100, y: screenSize.height - 60, width: 100, height: 50))
        let image = UIImage(named: "pausebutton")
        pauseButton.setImage(image, for: .normal)
        pauseButton.addTarget(self, action: #selector(pauseButtonAction(sender:)), for: .touchUpInside)
        self.view?.addSubview(pauseButton)
        
        resumeButton = UIButton(frame: CGRect(x: screenSize.width - 100, y: screenSize.height - 60, width: 100, height: 50))
        let image2 = UIImage(named: "playbutton")
        resumeButton.setImage(image2, for: .normal)
        resumeButton.addTarget(self, action: #selector(resumeButtonAction(sender:)), for: .touchUpInside)
        self.view?.addSubview(resumeButton)
        resumeButton.isHidden = true
        
        soundButton = UIButton(frame: CGRect(x: 0 + 100, y: screenSize.height - 60, width: 100, height: 50))
        soundButton.center.x = 50
        let soundimage = UIImage(named: "volumebutton")
        soundButton.setImage(soundimage, for: .normal)
        soundButton.addTarget(self, action: #selector(soundButtonAction(sender:)), for: .touchUpInside)
        self.view?.addSubview(soundButton)
        soundButton.isHidden = true
        
        bomb = UIButton(frame: CGRect(x: 0 + 50, y: screenSize.height - 60, width: 100, height: 50))
        bomb.center.x = 100
        let bombimage = UIImage(named: "boogablast")
        bomb.setImage(bombimage, for: .normal)
        bomb.addTarget(self, action: #selector(bombButtonAction(sender:)), for: .touchUpInside)
        self.view?.addSubview(bomb)
        bomb.isHidden = false
        
        quitButton = UIButton(frame: CGRect(x: screenSize.width / 2, y: screenSize.height / 2, width: 100, height: 50))
        quitButton.center.x = screenSize.width / 2
        quitButton.center.y = screenSize.height / 2
        let quitimage = UIImage(named: "quit")
        quitButton.setImage(quitimage, for: .normal)
        quitButton.addTarget(self, action: #selector(quitButtonAction(sender:)), for: .touchUpInside)
        self.view?.addSubview(quitButton)
        quitButton.isHidden = true
        
        // Create shape node to use during mouse interaction
        self.sparkNode = SKEmitterNode(fileNamed: "spark.sks")
        self.sparkNode?.zPosition = 2
    
        
        health = 20
        
        alienNumber = 0
        aliensHit = 0
        score = 0
        alienStart = 0
        maxAliens = 5
        
        asteroidNumber = 0
        
        wave = 1
        counter = 1
        
        heartsOnScreen = 0
        seconds = 5.0
        seconds2 = 0.6
        maxxJoystickDelta = (pad.frame.size.width) / 2
        maxyJoystickDelta = (pad.frame.size.height) / 2
        gamePaused = false
        gameOver = false
        exploding = false
        updateTimers()
        updateBombTimers()
        addBomb()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.sparkNode?.copy() as! SKEmitterNode? {
            n.position = pos
            //self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.sparkNode?.copy() as! SKEmitterNode? {
            n.position = pos
                       // self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.sparkNode?.copy() as! SKEmitterNode? {
            n.position = pos
            //self.addChild(n)
        }
    }
    
    
    
    
    
    
    
    
    //if one touch is used 
    //changes position of joystick
    //checks if you're in the restart button
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
            location = t.location(in: self)
            //checks if the game isn't over or paused so that it knows to put a joystick wherever it is touched
            if gameOver == false && gamePaused == false {
                pad.removeFromParent()
                ball.removeFromParent()
                pad.position = location
                ball.position = location
                self.addChild(pad)
                self.addChild(ball)
            }
            //if you're in this, change back to the menu
            if restartButton.contains(location) && gameOver == true{
                let transition = SKTransition.reveal(with: .down, duration: 1.0)
                
                let nextScene = GameScene(size: scene!.size)
                nextScene.scaleMode = .aspectFill
                
                scene?.view?.presentScene(nextScene, transition: transition)
            }
        }
    }
    
    //movement of the spaceship
    //movement of the aliens
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver == false && gamePaused == false {
            for touch : AnyObject in touches {
                location = touch.location(in: self)
                ball.position = location
                
                let v = CGVector(dx: location.x - pad.position.x, dy: location.y - pad.position.y)
                
                
                xJoystickDelta = location.x - pad.position.x
                yJoystickDelta = location.y - pad.position.y
                
                //these cap the max speed so that the joystick isn't just accounting for touch in its area
                if xJoystickDelta > maxxJoystickDelta && xJoystickDelta > 0 {
                    xJoystickDelta = maxxJoystickDelta
                }
                if yJoystickDelta > maxyJoystickDelta && yJoystickDelta > 0 {
                    yJoystickDelta = maxyJoystickDelta
                }
                if abs(xJoystickDelta) > maxxJoystickDelta && xJoystickDelta < 0 {
                    xJoystickDelta = maxxJoystickDelta * -1
                }
                if abs(yJoystickDelta) > maxyJoystickDelta && yJoystickDelta < 0 {
                    yJoystickDelta = maxyJoystickDelta * -1
                }
                
                //check the angle by getting the inverse tangent of the difference in distance for x and y
                var angleInRadians = atan2(v.dy, v.dx) - CGFloat(M_PI_2)
                
                if(angleInRadians < 0){
                    angleInRadians = angleInRadians + 2 * CGFloat(M_PI)
                }
                
                
                spaceship.zRotation = angleInRadians
                
                let actionAngle = SKAction.rotate(toAngle: angleInRadians, duration: 0.0)
                spaceship.run(actionAngle)
                
                
                //move the aliens accordingly
                if alienNumber > 0{
                 
                    var alienFollow:Int = 0
                    var v:CGVector!
                    
                    for i in alienStart..<aliens.count {
                        var actionArray = [SKAction]()
                        var tempAlienNumb = i
                        while tempAlienNumb > -1 {
                            //if the alien is the first of the wave then follow the spaceship
                            if tempAlienNumb == alienStart {
                                let newX = self.spaceship.position.x
                                let newY = self.spaceship.position.y
                                actionArray.append(SKAction.move(to: CGPoint(x: newX, y: newY), duration: TimeInterval(1.0)))
                                v = CGVector(dx: spaceship.position.x - aliens[i].position.x, dy: spaceship.position.y - aliens[i].position.y)
                                break
                            }
                            //if the alien in front of the spaceship is not dead follow it
                            if alienDead[tempAlienNumb - 1] == false {
                                alienFollow = tempAlienNumb - 1
                                let newX = aliens[alienFollow].position.x
                                let newY = aliens[alienFollow].position.y
                                actionArray.append(SKAction.move(to: CGPoint(x: newX, y: newY), duration: TimeInterval(1.0)))
                                v = CGVector(dx: aliens[alienFollow].position.x - aliens[i].position.x, dy: aliens[alienFollow].position.y - aliens[i].position.y)
                                break
                            }
                            tempAlienNumb -= 1
                            //if no position is emitted explode the alien, no score added
                            if tempAlienNumb == -1 {
                                let explosion = SKEmitterNode(fileNamed: "Explosion")!
                                explosion.position = aliens[i].position
                                self.addChild(explosion)
                                
                                self.run(SKAction.playSoundFileNamed("crash3.wav", waitForCompletion: false))
                                
                                self.run(SKAction.wait(forDuration: 2)) {
                                    explosion.removeFromParent()
                                }
                                aliens[i].removeFromParent()
                                break
                                
                            }
                        }
                        //rotate the shit out of the aliens
                        self.aliens[i].run(SKAction.sequence(actionArray))
                        
                        
                        
                        var angleInRadians = atan2(v.dy, v.dx) - CGFloat(M_PI_2)
                        
                        if(angleInRadians < 0){
                            angleInRadians = angleInRadians + 2 * CGFloat(M_PI)
                        }
                        
                        
                        aliens[i].zRotation = angleInRadians
                        
                        let actionAngle = SKAction.rotate(toAngle: angleInRadians, duration: 0.0)
                        aliens[i].run(actionAngle)
                    }
                    
                }
            
        }
       
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
        }
    }
    
        
        
        
        
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    

    
    
    
    //function for adding the alien
    //changes according with time
    func addAlien() {
        //check if conditions are met ie game is being played
        if gameOver == false && gamePaused == false{
            if alienNumber < maxAliens{
                var boss:Int = 0
                if alienNumber == alienStart {
                    boss = 1
                }
                else {
                    boss = 2
                }
                let alien = SKSpriteNode(imageNamed: "badguy\(boss)")
                //get a random position to start
                let random = Int(arc4random() % UInt32(4))
                //left
                if random == 1 {
                    alien.position = CGPoint(x: Int(0 - alien.frame.size.width), y: Int(arc4random() % UInt32(screenSize.height)) * 2)
                }
                //right
                if random == 2 {
                    alien.position = CGPoint(x: Int((screenSize.width * 2)  + alien.frame.size.width), y: Int(arc4random() % UInt32(screenSize.height)) * 2)
                }
                //top
                if random == 3 {
                    alien.position = CGPoint(x: Int(arc4random() % UInt32(screenSize.width)) * 2, y: Int(screenSize.height * 2 + alien.frame.size.width))
                }
                //bottom
                if random == 0 {
                    alien.position = CGPoint(x: Int(arc4random() % UInt32(screenSize.width)) * 2, y: Int(0 - alien.frame.size.height))
                }
                aliens.append(alien)
                alienRand.append(random)
                alienDead.append(false)
                
                self.addChild(alien)
                var actionArray = [SKAction]()
                actionArray.append(SKAction.move(to: CGPoint(x: spaceship.position.x, y: spaceship.position.y), duration: 1.0)  )
                alien.run(SKAction.sequence(actionArray), withKey: "start")
                alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
                alien.physicsBody?.isDynamic = true
                
                alien.physicsBody?.categoryBitMask = alienCategory 
                alien.physicsBody?.contactTestBitMask = asteroidCategory | bombCategory
                alien.physicsBody?.collisionBitMask = asteroidCategory | bombCategory
                alienNumber+=1
            }
        }
        
        
    }
    //fire an alien torpedo
    func alienTorpedoFire() {
        //check if condition are met ie game is being played
        if gameOver == false && gamePaused == false{
            for i in alienStart..<aliens.count {
                let random = Int(arc4random() % UInt32(4))
                //if the random number is a certain value don't fire the torpedo
                //helps to balance the game
                if alienDead[i] == false && random % 2 == 0{
                    let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
                    self.run(SKAction.playSoundFileNamed("pew.wav", waitForCompletion: false))
                    
                    torpedoNode.position = aliens[i].position
                    torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
                    torpedoNode.physicsBody?.isDynamic = true
                    
                    torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
                    torpedoNode.physicsBody?.contactTestBitMask = asteroidCategory | spaceshipCategory | bombCategory
                    torpedoNode.physicsBody?.collisionBitMask = asteroidCategory | bombCategory
                    
                    self.addChild(torpedoNode)
                    torpedos.append(torpedoNode)
                    
                    let animationDuration:TimeInterval = 1.5
                    var actionArray = [SKAction]()
                    let dx1 = (aliens[i].position.x - spaceship.position.x) * 5
                    let dy1 = (aliens[i].position.y - spaceship.position.y) * 5
                    
                    let newX = aliens[i].position.x - dx1
                    let newY = aliens[i].position.y - dy1
                    
                    actionArray.append(SKAction.move(to: CGPoint(x: newX, y: newY), duration: animationDuration))
                    actionArray.append(SKAction.removeFromParent())
                    torpedoNode.run(SKAction.sequence(actionArray), withKey: "moving")
                }
                else {
                    
                }
            }
        }
        
    }
    
    //add the asteroid to the view
    func addAsteroid() {
        //check the conditions
        if gameOver == false && gamePaused == false{
            var asteroidNumber = Int(arc4random() % UInt32(3) + 1)
            let asteroid = SKSpriteNode(imageNamed: "asteroid\(asteroidNumber)")
            //generate a random number to figure out a random position
            let random = Int(arc4random() % UInt32(4))
            //left
            if random == 1 {
                asteroid.position = CGPoint(x: Int(0 - asteroid.frame.size.width), y: Int(arc4random() % UInt32(screenSize.height)) * 2)
                //give a random velocity
                asteroidXvelo.append(CGFloat(arc4random() % UInt32(2) + 1))
                asteroidYvelo.append(CGFloat(arc4random() % UInt32(5) + 1))
            }
            //right
            if random == 2 {
                asteroid.position = CGPoint(x: Int((screenSize.width * 2)  + asteroid.frame.size.width), y: Int(arc4random() % UInt32(screenSize.height)) * 2)
                //give a random velocity
                var xvelo = CGFloat(arc4random() % UInt32(2) + 1)
                xvelo *= -1
                asteroidXvelo.append(xvelo)
                asteroidYvelo.append(CGFloat(arc4random() % UInt32(5) + 1))
            }
            //top
            if random == 3 {
                asteroid.position = CGPoint(x: Int(arc4random() % UInt32(screenSize.width)) * 2, y: Int(screenSize.height * 2 + asteroid.frame.size.height))
                //give a random velocity
                var yvelo = CGFloat(arc4random() % UInt32(2) + 1)
                yvelo *= -1
                asteroidXvelo.append(CGFloat(arc4random() % UInt32(5) + 1))
                asteroidYvelo.append(yvelo)
                
            }
            //bottom
            if random == 0 {
                asteroid.position = CGPoint(x: Int(arc4random() % UInt32(screenSize.width)) * 2, y: Int(0 - asteroid.frame.size.height))
                //give a random velocity
                asteroidXvelo.append(CGFloat(arc4random() % UInt32(5) + 1))
                asteroidYvelo.append(CGFloat(arc4random() % UInt32(2) + 1))
            }
            asteroids.append(asteroid)
            asteroidNumber += 1
            self.addChild(asteroid)
            asteroid.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 2)))
            //addd the physics body
            asteroid.physicsBody = SKPhysicsBody(rectangleOf: asteroid.size)
            asteroid.physicsBody?.isDynamic = true
            asteroid.physicsBody?.usesPreciseCollisionDetection = true
            
            asteroid.physicsBody?.categoryBitMask = asteroidCategory
            asteroid.physicsBody?.contactTestBitMask = asteroidCategory | alienCategory | spaceshipCategory | photonTorpedoCategory |  bombCategory
            asteroid.physicsBody?.collisionBitMask = asteroidCategory | spaceshipCategory | alienCategory
        }
        
    }
    
    //add heart to screen
    func addHeart() {
        //check if conditions are met
        //heart on screen can't be greater than 1
        if heartsOnScreen == 0 && gamePaused == false && gameOver == false{
            heart = SKSpriteNode(imageNamed: "heart")
            
            heart.position = CGPoint(x: Int(arc4random() % UInt32(screenSize.width)) * 2, y: Int(arc4random() % UInt32(screenSize.height)) * 2)
            //add heart physics body
            heart.physicsBody = SKPhysicsBody(circleOfRadius: heart.size.width / 2)
            heart.physicsBody?.isDynamic = true
            
            heart.physicsBody?.categoryBitMask = heartCategory
            heart.physicsBody?.contactTestBitMask = spaceshipCategory
            heart.physicsBody?.collisionBitMask = spaceshipCategory
            
            self.addChild(heart)
            heartsOnScreen += 1

        }
    

    }
    //add bomb which is the button but don't set if off yet
    func addBomb() {
        if bomb.isHidden == true && exploding == false{
            bomb.isHidden = false
        }
        if bomb.isHidden == false {
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //functions is used for detecting the contact between the physics bodies
    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver == false && gamePaused == false {
            //make a first body and second body
            var firstBody:SKPhysicsBody
            var secondBody:SKPhysicsBody
            //if first body value is less than the second then switch the values
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            }
            else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            //asteroid and spaceship
            if (firstBody.categoryBitMask & asteroidCategory) != 0 && (secondBody.categoryBitMask & spaceshipCategory) != 0 {
                asteroidDidCollideSpaceship(asteroidNode: firstBody.node as! SKSpriteNode, spaceshipNode: secondBody.node as! SKSpriteNode)
            }
            //torpedo and asteroid
            if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & asteroidCategory) != 0 {
                torpeoDidCollideAsteroid(torpedoNode: firstBody.node as! SKSpriteNode, asteroidNode: secondBody.node as! SKSpriteNode)
            }
            //asteroid and alien
            if (firstBody.categoryBitMask & asteroidCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
                alienDidCollideAsteroid(asteroidNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
            }
            //torpedo and spaceship
            if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & spaceshipCategory) != 0 {
                torpeoDidCollideSpaceship(torpedoNode: firstBody.node as! SKSpriteNode, spaceshipNode: secondBody.node as! SKSpriteNode)
            }
            //spaceship and heart
            if (firstBody.categoryBitMask & spaceshipCategory) != 0 && (secondBody.categoryBitMask & heartCategory) != 0 {
                spaceshipDidCollideHeart(spaceshipNode: firstBody.node as! SKSpriteNode, heartNode: secondBody.node as! SKSpriteNode)
            }
            //asteroid and bomb
            if (firstBody.categoryBitMask & asteroidCategory) != 0 && (secondBody.categoryBitMask & bombCategory) != 0 {
                explosionDidCollideAsteroid(asteroidNode: firstBody.node as! SKSpriteNode, bombNode: secondBody.node as! SKSpriteNode)
            }
            //alien and bomb
            if (firstBody.categoryBitMask & alienCategory) != 0 && (secondBody.categoryBitMask & bombCategory) != 0 {
                explosionDidCollideAlien(alienNode: firstBody.node as! SKSpriteNode, bombNode: secondBody.node as! SKSpriteNode)
            }
            //torpedo and bomb
            if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & bombCategory) != 0 {
                explosionDidCollideTorpedo(torpedoNode: firstBody.node as! SKSpriteNode, bombNode: secondBody.node as! SKSpriteNode)
            }
            
        }
    }
    
    
    
    
    
        //add all the collsion functions
    
    

    func asteroidDidCollideSpaceship(asteroidNode:SKSpriteNode, spaceshipNode:SKSpriteNode) {
        //add crack
        asteroidNumber -= 1
        if health > 1 {
            health -= 1
            let explosion = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = spaceshipNode.position
            self.addChild(explosion)
            
            self.run(SKAction.playSoundFileNamed("crash3.wav", waitForCompletion: false))
            asteroidNode.removeFromParent()
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
            }
        }
        else {
            let explosion = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = spaceshipNode.position
            self.addChild(explosion)
            
            spaceshipNode.removeFromParent()
            asteroidNode.removeFromParent()
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
            }
                self.removeAllActions()
                self.removeAllChildren()
                self.asteroidTimer.invalidate()
                self.gameOver = true
                endGame()
            
        }
        

    }
    
    func torpeoDidCollideAsteroid(torpedoNode:SKSpriteNode, asteroidNode:SKSpriteNode) {
        asteroidNumber -= 1
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = torpedoNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("crash3.wav", waitForCompletion: false))
        torpedoNode.removeFromParent()
        asteroidNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        
    }
    
    func torpeoDidCollideSpaceship(torpedoNode:SKSpriteNode, spaceshipNode:SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "smoke")!
        explosion.position = torpedoNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("crash1.wav", waitForCompletion: false))
        torpedoNode.removeFromParent()
        self.run(SKAction.wait(forDuration: 0.3)) {
            explosion.removeFromParent()
        }
        if health > 1 {
            health -= 1
        }
        else {
            let explosion = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = spaceshipNode.position
            self.addChild(explosion)
            
            spaceshipNode.removeFromParent()
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
            }
            
                self.removeAllActions()
                self.removeAllChildren()
                self.asteroidTimer.invalidate()
                self.gameOver = true
                endGame()
        
        }
        
        
    }
    
    func alienDidCollideAsteroid(asteroidNode:SKSpriteNode, alienNode:SKSpriteNode) {
        if alienNode.action(forKey: "start") != nil {
        
        }
        else {
            asteroidNumber -= 1
            let explosion = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = alienNode.position
            self.addChild(explosion)
            
            self.run(SKAction.playSoundFileNamed("crash2.wav", waitForCompletion: false))
            for i in alienStart..<aliens.count {
                if explosion.position == aliens[i].position {
                    alienDead[i] = true
                    aliens[i].removeFromParent()
                }
            }
            alienNode.removeFromParent()
            asteroidNode.removeFromParent()
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
            }
            //each times aliens die check if the wave has been completed
            aliensHit += 1
            score += 1
            if aliensHit == maxAliens {
                if counter != 1 {
                    addBomb()
                }
                counter += 1
                wave += 1
                if wave == 2 {
                    princeOn = true
                }
                print(wave)
                updateTimers()
                
                alienStart = alienNumber
                maxAliens += alienNumber
            }
        }
        
        
    }
    
    
    func spaceshipDidCollideHeart(spaceshipNode:SKSpriteNode, heartNode:SKSpriteNode) {
        
        heartNode.removeFromParent()
        self.run(SKAction.playSoundFileNamed("whoohoo.wav", waitForCompletion: false))
        
        health += 1
        heartsOnScreen -= 1
        
    }
    
    func explosionDidCollideAsteroid(asteroidNode:SKSpriteNode, bombNode:SKSpriteNode) {
        //print("here")
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = asteroidNode.position
        self.addChild(explosion)
        
        asteroidNode.removeFromParent()
        self.run(SKAction.wait(forDuration: 1)) {
            explosion.removeFromParent()
        }
        
    }
    func explosionDidCollideAlien(alienNode:SKSpriteNode, bombNode:SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        for i in alienStart..<aliens.count {
            if explosion.position == aliens[i].position {
                alienDead[i] = true
                aliens[i].removeFromParent()
            }
        }
        alienNode.removeFromParent()
        self.run(SKAction.wait(forDuration: 1)) {
            explosion.removeFromParent()
        }
        //each times aliens die check if the wave has been completed
        aliensHit += 1
        score += 1
        if aliensHit == maxAliens {
            if counter != 1 {
                addBomb()
            }
            counter += 1
            wave += 1
            if wave == 2 {
                princeOn = true
            }
            print(wave)
            updateTimers()
            
            alienStart = alienNumber
            maxAliens += alienNumber
        }
    }
    func explosionDidCollideTorpedo(torpedoNode:SKSpriteNode, bombNode:SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "smoke")!
        explosion.position = torpedoNode.position
        self.addChild(explosion)
        
        torpedoNode.removeFromParent()
        self.run(SKAction.wait(forDuration: 1)) {
            explosion.removeFromParent()
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //end game is called to move the screen to the final score and add quotes to the scene
    func endGame() {
        self.addChild(background)
        self.run(SKAction.playSoundFileNamed("dying sound.wav", waitForCompletion: false))
        pauseButton.isHidden = true
        bomb.isHidden = true
        bgMusic.stop()
        //finish the final touches of adding  the quotes 
        //look for a random quote
        let highScoreDefault = UserDefaults.standard
        if  highScoreDefault.value(forKey: "highscore") != nil {
            highscore = highScoreDefault.value(forKey: "highscore") as! NSInteger
        }
        if score > highscore {
            highscore = score
            scoreLabel.fontColor = UIColor.green
            highScoreLabel = SKLabelNode(text: "NEW HIGHSCORE!!!")
            highScoreLabel.position = CGPoint(x: screenSize.width, y: self.frame.size.height - 60)
            highScoreLabel.fontName = "AmericanTypewriter-Bold"
            highScoreLabel.fontSize = 48
            highScoreLabel.fontColor = UIColor.green
            self.addChild(highScoreLabel)
            highScoreDefault.set(highscore, forKey: "highscore")
            highScoreDefault.synchronize()
        }
        let random1 = Int(arc4random() % UInt32(quotes.count))
        let random2 = Int(arc4random() % UInt32(people.count))
        quoteLabel.text = quotes[random1]
        peopleLabel.text = people[random2]
        scoreLabel.position = CGPoint(x: screenSize.width, y: ((screenSize.height * 2) / 4) * 3)
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 54
        self.addChild(scoreLabel)
        self.addChild(quoteLabel)
        self.addChild(peopleLabel)
        self.addChild(restartButton)
    }
    
    //for retrieving the high score
    func getHighScore() -> (Int) {
        
        let highScoreDefault = UserDefaults.standard
        if  highScoreDefault.value(forKey: "highscore") != nil {
            highscore = highScoreDefault.value(forKey: "highscore") as! NSInteger
        }
        if score > highscore {
            highscore = score
            scoreLabel.fontColor = UIColor.green
            highScoreDefault.set(highscore, forKey: "highscore")
            highScoreDefault.synchronize()
        }
        return highscore
    }
    
    
    
    
    
    
    //button actions
    func pauseButtonAction(sender: UIButton!) {
        //hide all the things that need to be hidden
        soundButton.isHidden = false
        resumeButton.isHidden = false
        pauseButton.isHidden = true
        quitButton.isHidden = false
        bomb.isHidden = true
        pad.removeFromParent()
        ball.removeFromParent()
        //pause the game
        gamePaused = true
        //if the speed of the torpedos is above zero then set it to zero
        for i in 0..<torpedos.count {
            if let action = torpedos[i].action(forKey: "moving") {
                action.speed = 0
            }
        }
        for i in alienStart..<aliens.count {
            aliens[i].removeAllActions()
        }
    }
    
    func resumeButtonAction(sender: UIButton!) {
        //hide everything that needs to be hidden
        soundButton.isHidden = true
        resumeButton.isHidden = true
        pauseButton.isHidden = false
        quitButton.isHidden = true
        bomb.isHidden = false
        gamePaused = false
        //if the speed of an object is zero set it to 1
        for i in 0..<torpedos.count {
            if let action = torpedos[i].action(forKey: "moving") {
                action.speed = 1
            }
        }
    }
    //sound button
    func soundButtonAction(sender: UIButton!) {
        //check if it is being played or not
        //whatever action is happening change it to the opposite and change the image
        if musicPlayed == true {
            let soundimage = UIImage(named: "mutebutton")
            soundButton.setImage(soundimage, for: .normal)
            bgMusic.pause()
        }
        if musicPlayed == false {
            let soundimage = UIImage(named: "volumebutton")
            soundButton.setImage(soundimage, for: .normal)
            bgMusic.play()
        }
        musicPlayed = !musicPlayed

    }
    //action of adding the boogablast to the screen
    func bombButtonAction(sender: UIButton!) {
        bomb.isHidden = true
        exploding = true
        counter = 1
        self.run(SKAction.playSoundFileNamed("boogablast.wav", waitForCompletion: false))
        bombExplosion.position = spaceship.position
        bombExplosion.size = CGSize(width: spaceship.size.width, height: spaceship.size.height)
        //set physics body to the size of the screen
        bombExplosion.physicsBody = SKPhysicsBody(circleOfRadius: screenSize.width * 2)
        bombExplosion.physicsBody?.isDynamic = true
        
        bombExplosion.physicsBody?.categoryBitMask = bombCategory
        bombExplosion.physicsBody?.contactTestBitMask = asteroidCategory | alienCategory | photonTorpedoCategory | princeCategory
        bombExplosion.physicsBody?.collisionBitMask = asteroidCategory | photonTorpedoCategory | princeCategory
        self.addChild(bombExplosion)
        
        
    }
    func quitButtonAction(sender: UIButton!) {
        bgMusic.stop()
        quitButton.isHidden = true
        pauseButton.isHidden = true
        resumeButton.isHidden = true
        soundButton.isHidden = true
        let transition = SKTransition.reveal(with: .down, duration: 1.0)
        
        let nextScene = GameScene(size: scene!.size)
        nextScene.scaleMode = .aspectFill
        
        scene?.view?.presentScene(nextScene, transition: transition)
        
        
    }
    
    
    
    
    
    
    
    
    
    //for the timers that change throughout the game
    //alien timer and asteroid timer
    func updateTimers() {
        //cap off the alien timer
        if seconds >= 0.5 {
            seconds = 0.9 * seconds
        }
        //cap off the asteroid timer
        if seconds2 >= 0.05 {
            seconds2 = 0.9 * seconds2
        }
        self.alienTimer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        self.asteroidTimer = Timer.scheduledTimer(timeInterval: seconds2, target: self, selector: #selector(addAsteroid), userInfo: nil, repeats: true)
    }
    func updateBombTimers() {
        
    }
    
    
    
    
    
    
    
    
    
    //update every frame
    //for movement only
    override func update(_ currentTime: TimeInterval) {
        if gameOver == false && gamePaused == false {
            // Called before each frame is rendered
            let xScale:CGFloat = 0.032 //adjust to your preference
            let yScale:CGFloat = 0.032 //adjust to your preference
            
            //used for adding or subtracting from the spaceship asteroid and background
            let xAdd:CGFloat = xScale * self.xJoystickDelta
            let yAdd:CGFloat = yScale * self.yJoystickDelta
            
            
            if spaceship.position.x <= 0{
                spaceship.position.x += 10
                background.position.x -= 5
            }
            
            if spaceship.position.x >= screenSize.width * 2{
                spaceship.position.x -= 5
                background.position.x += 2.5
            }
            
            if spaceship.position.y <= 0{
                spaceship.position.y += 10
                background.position.y -= 5
            }
            
            if spaceship.position.y >= screenSize.height * 2{
                spaceship.position.y -= 5
                background.position.y += 2.5
            }
            
            self.spaceship.position.x += xAdd
            self.spaceship.position.y += yAdd
            
            if heartsOnScreen > 0 {
                heart.position.x -= xAdd
                heart.position.y -= yAdd
            }
            
            spaceshipHitBox.position = spaceship.position
            self.background.position.x -= xAdd / 2
            self.background.position.y -= yAdd / 2
            
            for i in 0..<asteroids.count {
                if !background.contains(asteroids[i].position) {
                    asteroids[i].removeFromParent()
                }
                else {
                    self.asteroids[i].position.x -= xAdd
                    self.asteroids[i].position.y -= yAdd
                    self.asteroids[i].position.x += asteroidXvelo[i]
                    self.asteroids[i].position.y +=  asteroidYvelo[i]
                }
            }
            
            for i in alienStart..<aliens.count {
                aliens[i].position.x -= xAdd
                aliens[i].position.y -= yAdd
            }
            if exploding == true {
                if bombExplosion.size.width < screenSize.width * 100 {
                    bombExplosion.size.width *= 1.9
                    bombExplosion.size.height *= 1.9

                }
                if bombExplosion.size.width > screenSize.width * 100 {
                    exploding = false
                }
            }
            if exploding == false{
                bombExplosion.removeFromParent()
                
            }
        }
    }
}
