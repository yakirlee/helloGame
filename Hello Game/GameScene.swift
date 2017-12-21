//
//  GameScene.swift
//  Hello Game
//
//  Created by 李 on 2017/12/20.
//  Copyright © 2017年 Archerycn. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVKit

class GameScene: SKScene {
    
    var palyerAudio: AVAudioPlayer!
    var monsters = NSMutableArray()
    var projectiles = NSMutableArray()
    var projectileSoundEffectAction = SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false)
    let numberLabel = SKLabelNode(text: "\(0)")
    var destoryedMosterNumbers = 0 {
        didSet{
            numberLabel.text = "\(destoryedMosterNumbers)"
        }
    }
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        numberLabel.fontName = "Chalkduster"
        numberLabel.fontSize = 30
        numberLabel.fontColor = SKColor.black
        numberLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(numberLabel)
        
        let bgm = Bundle.main.path(forResource: "background-music-aac", ofType: "caf")
        palyerAudio = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: bgm ?? ""))
        palyerAudio.numberOfLoops = -1
        palyerAudio.play()
        
        backgroundColor = SKColor(red: 1, green: 1, blue: 1, alpha: 1)
        let player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 20, y: frame.height / 2)
        addChild(player)
        addMonster()
        
        let actionAddMonster = SKAction.run {
            self.addMonster()
        }
        let actionWaitNextMonster = SKAction.wait(forDuration: 1)
        run(SKAction.repeatForever(SKAction.sequence([actionAddMonster, actionWaitNextMonster])))
        actionWaitNextMonster.reversed()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func addMonster() {
        let monster = SKSpriteNode(imageNamed: "monster")
        let minY = monster.size.height / 2
        let maxY = size.height - minY
        let rangeY = maxY - minY
        let actualY = arc4random() % UInt32(rangeY) + UInt32(minY)
        
        monster.position = CGPoint(x: size.width + monster.size.width / 2, y: CGFloat(actualY))
        addChild(monster)
        monsters.add(monster)
        
        let minDuration = 2
        let maxDuration = 4
        let rangedRuration = maxDuration - minDuration
        let actualDuration = arc4random() % UInt32(rangedRuration) + UInt32(minDuration)
        
        let actionMove = SKAction.move(to: CGPoint.init(x: -monster.size.width / 2, y: CGFloat(actualY)), duration: TimeInterval(actualDuration))
        let actiomMoveDone = SKAction.run {
            monster.removeFromParent()
        }
        monster.run(SKAction.sequence([actionMove, actiomMoveDone]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let project = SKSpriteNode(imageNamed: "projectile")
            project.position = CGPoint(x: 20, y: frame.height / 2)
            let location = touch.location(in: self)
            let offset = CGPoint(x: location.x - project.position.x, y: location.y - project.position.y)
            
            if offset.x <= 0 { return }
            
            addChild(project)
            projectiles.add(project)
            
            let realX = size.width + project.size.width / 2
            let ratio = offset.y / offset.x
            let realY = realX * ratio + project.position.y
            let realDest = CGPoint(x:realX, y: realY)
            
            let offRealX = realX - project.position.x
            let offRealY = realY - project.position.y
            let length = sqrt(offRealX * offRealX + offRealY * offRealY)
            let velocity = size.width
            let realMoveDuration = length / velocity
            
            let moveAction = SKAction.move(to: realDest, duration: TimeInterval(realMoveDuration))
            let projectileCast = SKAction.group([moveAction, projectileSoundEffectAction])
            project.run(projectileCast, completion: {
                project.removeFromParent()
                self.projectiles.remove(project)
            })
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        let projectToDelegate = NSMutableArray()
        for project in projectiles {
            let project = project as! SKSpriteNode
            let monsterToDelegate = NSMutableArray()
            for monster in monsters {
                let monster = monster as! SKSpriteNode
                if project.frame.intersects(monster.frame) {
                    monsterToDelegate.add(monster)
                    destoryedMosterNumbers += 1
                    if destoryedMosterNumbers >= 20 {
                        numberLabel.text = "you win"
                        palyerAudio.stop()
                        isUserInteractionEnabled = false
                    }
                }
            }
            for monster in monsterToDelegate {
                let monster = monster as! SKSpriteNode
                monsters.remove(monster)
                monster.removeFromParent()
            }
            if monsterToDelegate.count > 0 {
                projectToDelegate.add(project)
            }
        }
        for project in projectToDelegate {
            let project = project as! SKSpriteNode
            projectiles.remove(project)
            project.removeFromParent()
        }
    }
}
