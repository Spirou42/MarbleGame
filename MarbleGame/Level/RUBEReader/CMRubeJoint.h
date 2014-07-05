//
//  CMRubeJoint.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kRubeJoint_Undefined 	= -1,
	kRubeJoint_Revolute 	= 0,
	kRubeJoint_Distance,
	kRubeJoint_Prismatic,
	kRubeJoint_Wheel,
	kRubeJoint_Rope,
	kRubeJoint_Motor,
	kRubeJoint_Weld,
	kRubeJoint_Friction
}CMRubeJointType;

@class CMPhysicsJointSprite,CMRubeBody;

@interface CMRubeJoint : NSObject <ChipmunkObject>

@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) CMRubeJointType type;
@property (nonatomic, assign) CMRubeBody* bodyA, *bodyB;

//revolute
@property (nonatomic, assign) CGPoint anchorA,anchorB;
@property (nonatomic, assign) NSInteger bodyAIndex,bodyBIndex;
@property (nonatomic, assign) BOOL collideConnected;
@property (nonatomic, assign) BOOL enableLimit;
@property (nonatomic, assign) BOOL enableMotor;
@property (nonatomic, assign) CGFloat motorSpeed;
@property (nonatomic, assign) CGFloat jointSpeed;
@property (nonatomic, assign) CGFloat lowerLimit, upperLimit;
@property (nonatomic, assign) CGFloat maxMotorSpeed,maxMotorTorque;

//Distance
@property (nonatomic, assign) CGFloat dampingRatio,frequency,length;

//Prismatic
@property (nonatomic, assign) CGPoint localAxisA;
@property (nonatomic, assign) CGFloat refAngle;


// Wheel
@property (nonatomic, assign) CGFloat springDampingRatio,springFrequency;

// Rope
@property (nonatomic, assign) CGFloat maxLength;

// Motor
@property (nonatomic, assign) CGFloat maxTorque, maxForce, correctionFactor;

// Weld

// Friction

// customProperties
@property (nonatomic, retain) NSString *imageA;
@property (nonatomic, retain) NSString *imageB;
@property (nonatomic, assign) CGPoint imageAnchorA;
@property (nonatomic, assign) CGPoint imageAnchorB;
@property (nonatomic, assign) CGRect  imageCapsA;
@property (nonatomic, assign) CGRect imageCapsB;
@property (nonatomic, readonly) CMPhysicsJointSprite* physicsSprite;


- (id) initWithDictionary:(NSDictionary*) dict;
- (id) initWithDictionary:(NSDictionary *)dict andBodies:(NSArray*) bodies;

- (NSArray*) chipmunkObjects;

@end
