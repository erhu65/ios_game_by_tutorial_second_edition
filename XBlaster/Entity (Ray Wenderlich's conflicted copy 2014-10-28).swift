/*
 * Copyright (c) 2013-2014 Razeware LLC
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit

class Entity: SKSpriteNode {

  // This structure is used to provide bit masks for the physics collision detection
  // implemented within each enemy and the GameScene
  struct ColliderType {
    static var Player: UInt32 = 1
    static var Enemy: UInt32 = 2
    static var Bullet: UInt32 = 4
  }
  
  required init(coder aDecoder: NSCoder) {
    [super.init(coder: aDecoder)]
  }

  // 1
  var direction = CGPointZero
  var health = 100.0
  var maxHealth = 100.0
  // 2
  init(position: CGPoint, texture: SKTexture) {
    super.init(texture: texture, color: SKColor.whiteColor(),
               size: texture.size())
    self.position = position
  }
  // 3
  class func generateTexture() -> SKTexture? {
    // Overridden by subclasses
    return nil
  }
  // 4
  func update(delta: NSTimeInterval) {
    // Overridden by subclasses
  }
  
  func collidedWith(body: SKPhysicsBody, contact: SKPhysicsContact) {
    // Overridden by subsclasses to implement actions to be carried out when an entity
    // collides with another entity e.g. PlayerShip or Bullet
  }  
  
}
