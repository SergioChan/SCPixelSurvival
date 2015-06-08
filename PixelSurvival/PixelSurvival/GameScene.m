//
//  GameScene.m
//  testGame1
//
//  Created by chen Yuheng on 15/6/1.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "GameScene.h"
#import <math.h>
static const uint32_t mainCategory  = 0x1 << 0;
static const uint32_t otherCategory  = 0x1 << 1;
#define PixelWidth 20.0f

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
//    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//    
//    myLabel.text = @"Hello, World!";
//    myLabel.fontSize = 65;
//    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
//                                   CGRectGetMidY(self.frame));
//    
//    [self addChild:myLabel];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    NSLog(@"fuck contact!!");
}

-(instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if(self)
    {
        self.view.multipleTouchEnabled = YES;
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = otherCategory;
        self.physicsBody.collisionBitMask = mainCategory;
        self.physicsBody.contactTestBitMask = mainCategory;
        self.mainPixelPathArray = [NSMutableArray arrayWithObjects:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithFloat:-PixelWidth/2],[NSNumber numberWithFloat:PixelWidth/2]] forKeys:@[@"x",@"y"]],[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithFloat:PixelWidth/2],[NSNumber numberWithFloat:PixelWidth/2]] forKeys:@[@"x",@"y"]],[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithFloat:PixelWidth/2],[NSNumber numberWithFloat:-PixelWidth/2]] forKeys:@[@"x",@"y"]],[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithFloat:-PixelWidth/2],[NSNumber numberWithFloat:-PixelWidth/2]] forKeys:@[@"x",@"y"]], nil];
        
        self.controlRangeRadius = 40.0f;
        self.pixel = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(20.0f, 20.0f)];
        //pixelNode.anchorPoint = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        _pixel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        _pixel.name = @"mainPixel";
        _pixel.physicsBody.dynamic = YES;
        _pixel.physicsBody.affectedByGravity = NO;
//        _pixel.physicsBody.velocity = self.physicsBody.velocity;
        
        CGMutablePathRef mainPath = CGPathCreateMutable();
        
        CGPathMoveToPoint(mainPath, NULL, [[[self.mainPixelPathArray objectAtIndex:0] objectForKey:@"x"] floatValue],[[[self.mainPixelPathArray objectAtIndex:0] objectForKey:@"y"] floatValue]);
        for(NSInteger i=1;i<self.mainPixelPathArray.count-1;i++)
        {
            CGPathAddLineToPoint(mainPath, NULL, [[[self.mainPixelPathArray objectAtIndex:i] objectForKey:@"x"] floatValue],  [[[self.mainPixelPathArray objectAtIndex:i] objectForKey:@"y"] floatValue]);
        }
        CGPathAddLineToPoint(mainPath, NULL, [[[self.mainPixelPathArray objectAtIndex:0] objectForKey:@"x"] floatValue],  [[[self.mainPixelPathArray objectAtIndex:0] objectForKey:@"y"] floatValue]);
        
        _pixel.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:mainPath];
        CGPathRelease(mainPath);
        
        _pixel.physicsBody.usesPreciseCollisionDetection = YES;
        _pixel.physicsBody.allowsRotation = YES;
        _pixel.physicsBody.categoryBitMask = mainCategory;
        _pixel.physicsBody.contactTestBitMask = otherCategory;
        _pixel.physicsBody.collisionBitMask = otherCategory;
        [self addChild:_pixel];
        [self spawnNewPixels];
    }
    return self;
}

- (void)spawnNewPixels
{
    SKSpriteNode *attach = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(20.0f, 20.0f)];
    attach.position = CGPointMake(self.pixel.position.x + 20.0f,self.pixel.position.y + 20.0f);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, - 10.0f,  10.0f);
    CGPathAddLineToPoint(path, NULL, 10.0f, 10.0f);
    CGPathAddLineToPoint(path, NULL, 10.0f,  - 10.0f);
    CGPathAddLineToPoint(path, NULL, - 10.0f,  - 10.0f);
    CGPathAddLineToPoint(path, NULL, - 10.0f, 10.0f);
    
    attach.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    CGPathRelease(path);
    
    attach.physicsBody.restitution = 0.5;
    attach.physicsBody.dynamic = YES;
    attach.physicsBody.affectedByGravity = NO;
    attach.physicsBody.categoryBitMask = otherCategory;
    attach.physicsBody.contactTestBitMask = mainCategory;
    attach.physicsBody.collisionBitMask = otherCategory;
    [self addChild:attach];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"%@",touches);
    if(touches.count == 2)
    {
        //_pixel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        BOOL flag = FALSE;
        UITouch *touchToBeCalculated = [[UITouch alloc]init];
        for(UITouch *touch in touches)
        {
            if(touch.phase == UITouchPhaseMoved)
            {
                flag = TRUE;
                touchToBeCalculated = touch;
            }
        }
        if(flag)
        {
            CGPoint previous = [touchToBeCalculated previousLocationInNode:self];
            CGPoint current = [touchToBeCalculated locationInNode:self];
            CGPoint origin = self.pixel.position;

            SKAction *action = [SKAction rotateByAngle:[self calculateRotationDegreeWithPrevious:previous andCurrent:current andOrigin:origin] duration:0];
            action.speed = 2.0f;
            [self.pixel runAction:action];
        }
        NSLog(@"double touch:");
    }
    else if(touches.count == 1)
    {
        for(UITouch *touch in touches)
        {
            // only react when moving
            if(touch.phase == UITouchPhaseMoved)
            {
                CGPoint previous = [touch previousLocationInNode:self];
                CGPoint current = [touch locationInNode:self];
                //CGPoint origin = self.pixel.position;
                CGPoint translation = CGPointMake(current.x - previous.x, current.y - previous.y);
                [self panForTranslation:translation];
            }
        }
    }
}

- (void)panForTranslation:(CGPoint)translation {
    CGPoint position = [_pixel position];
    if([[_pixel name] isEqualToString:@"mainPixel"]) {
        [_pixel setPosition:CGPointMake(position.x + translation.x, position.y + translation.y)];
    } else {
//        CGPoint newPos = CGPointMake(position.x + translation.x, position.y + translation.y);
//        [_background setPosition:[self boundLayerPos:newPos]];
    }
}

/**
 *  根据拖动的轨迹计算旋转的角度和方向
 *
 *  @param previous 前置坐标
 *  @param current  当前坐标
 *  @param origin   原点坐标
 *
 *  @return float 旋转角度值
 */
- (float)calculateRotationDegreeWithPrevious:(CGPoint)previous andCurrent:(CGPoint)current andOrigin:(CGPoint)origin
{
    CGFloat p_x = previous.x;
    CGFloat p_y = previous.y;
    CGFloat c_x = current.x;
    CGFloat c_y = current.y;
    CGFloat o_x = origin.x;
    CGFloat o_y = origin.y;
    
    float tmp_a = sqrtf(powf((p_y - c_y),2.0f) + powf((p_x - c_x),2.0f));
    float tmp_b = sqrtf(powf((p_y - o_y),2.0f) + powf((p_x - o_x),2.0f));
    float tmp_c = sqrtf(powf((o_y - c_y),2.0f) + powf((o_x - c_x),2.0f));
    
    float tmp = (powf(tmp_b, 2.0f) + powf(tmp_c, 2.0f) - powf(tmp_a, 2.0f))/(2.0f * tmp_b * tmp_c);
    float fuck = acosf(tmp);
    if(c_y >= p_y)
    {
        return fuck;
    }
    else
    {
        return (0 - fuck);
    }
}

/**
 *  检测是否进入控制拖动的区域
 *
 *  @param current 当前响应坐标
 *
 *  @return BOOL
 */
- (BOOL)checkIfInsideControlRange:(CGPoint)current withOrigin:(CGPoint)origin
{
    CGFloat c_x = current.x;
    CGFloat c_y = current.y;
    CGFloat o_x = origin.x;
    CGFloat o_y = origin.y;
    
    if(fabs(c_x - o_x)<=_controlRangeRadius && fabs(c_y - o_y)<=_controlRangeRadius)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
