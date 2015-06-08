//
//  GameScene.h
//  testGame1
//

//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate>
@property (nonatomic,strong) SKSpriteNode *pixel;
@property (nonatomic) CGFloat controlRangeRadius;
@property (nonatomic,strong) NSMutableArray *mainPixelPathArray;
@end
