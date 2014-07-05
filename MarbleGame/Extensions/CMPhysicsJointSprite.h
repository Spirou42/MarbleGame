//
//  CMPhysicsJointSprite.h
//  MarbleGame
//
//  Created by Carsten Müller on 05/07/14.
//  Copyright (c) 2014 Carsten Müller. All rights reserved.
//

#import "CCNode.h"
#import "CMRubeJoint.h"
#import "ChipmunkConstraint.h"
#import "CCScale9Sprite.h"


@interface CMPhysicsJointSprite : CCNode <ChipmunkObject,NSCopying>

@property (nonatomic, assign) ChipmunkDampedSpring* constraint;

@property (nonatomic, retain) CCScale9Sprite* spriteA;
@property (nonatomic, retain) CCScale9Sprite* spriteB;
@property (nonatomic, assign) CGPoint imageAnchorA;
@property (nonatomic, assign) CGPoint imageAnchorB;

+ (BOOL) canInitialiseWithJoint:(CMRubeJoint*) joint;
-(instancetype) initWithJoint:(CMRubeJoint*)joint;
@end
