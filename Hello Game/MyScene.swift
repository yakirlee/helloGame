//
//  MyScene.swift
//  Hello Game
//
//  Created by 李 on 2017/12/20.
//  Copyright © 2017年 Archerycn. All rights reserved.
//

import UIKit
import SpriteKit

class MyScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor(red: 1, green: 1, blue: 1, alpha: 1)
        let player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: player.size.width / 2, y: player.size.height / 2)
        addChild(player)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
