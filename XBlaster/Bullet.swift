//
//  Bullet.swift
//  XBlaster
//
//  Created by Main Account on 8/2/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import SpriteKit

class Bullet: Entity {

  required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
  }

  init(entityPosition: CGPoint) {
    let entityTexture = Bullet.generateTexture()!
    
    super.init(position: entityPosition, texture: entityTexture)
    
    name = "bullet"
  }
  
  override class func generateTexture() -> SKTexture? {
    struct SharedTexture {
      static var texture = SKTexture()
      static var onceToken: dispatch_once_t = 0
    }
    
    dispatch_once(&SharedTexture.onceToken, {
      let bullet = SKLabelNode(fontNamed: "Arial")
      bullet.name = "bullet"
      bullet.fontSize = 40
      bullet.fontColor = SKColor.whiteColor()
      bullet.text = "•"

      let textureView = SKView()
      SharedTexture.texture = 
        textureView.textureFromNode(bullet)
      SharedTexture.texture.filteringMode = .Nearest
    })
    
    return SharedTexture.texture
  }

}