//
//  CMPhysicsJointSprite.m
//  MarbleGame
//
//  Created by Carsten Müller on 05/07/14.
//  Copyright (c) 2014 Carsten Müller. All rights reserved.
//

#import "CMPhysicsJointSprite.h"
#import "CMRubeBody.h"
#import "CMRubeJoint.h"
@implementation CMPhysicsJointSprite

@synthesize constraint, spriteA, spriteB;

+ (BOOL) canInitialiseWithJoint:(CMRubeJoint*) joint
{
	BOOL result = NO;
	if (joint.imageA != nil){
		result = YES;
	}
	return result;
}



-(instancetype) initWithJoint:(CMRubeJoint*)joint
{
	self = [super init];
	self.layerName = joint.layerName;
	self.spriteA = [CCScale9Sprite spriteWithFile:joint.imageA capInsets:joint.imageCapsA];
	if (self.spriteA) {
		self.imageAnchorA = joint.imageAnchorA;
		self.spriteA.anchorPoint=ccp(  joint.imageAnchorA.x/self.spriteA.contentSize.width , joint.imageAnchorA.y / self.spriteA.contentSize.height  );
		self.spriteA.position = ccpAdd(joint.anchorA, joint.bodyA.position) ;
		[self addChild:self.spriteA];
		
	}
	self.spriteB = [CCScale9Sprite spriteWithFile:joint.imageB capInsets:joint.imageCapsB];
	if (self.spriteB) {
		self.imageAnchorB = joint.imageAnchorB;
    self.spriteB.anchorPoint = ccp(joint.imageAnchorB.x/self.spriteB.contentSize.width, joint.imageAnchorB.y/self.spriteB.contentSize.height);
		self.spriteB.position=ccpAdd(joint.anchorB, joint.bodyB.position);
		[self addChild:self.spriteB];
	}
	
	CGFloat dis = ccpDistance(self.spriteA.position, self.spriteB.position);
	CGSize cs = self.spriteA.contentSize;
	cs.width = dis/2.0+self.spriteA.anchorPointInPoints.x*2;
	self.spriteA.contentSize = cs;
	self.spriteA.anchorPoint = ccp(  self.imageAnchorA.x/self.spriteA.contentSize.width , self.imageAnchorA.y / self.spriteA.contentSize.height  );

	self.spriteB.contentSize = cs;
	self.spriteB.anchorPoint = ccp(  self.imageAnchorB.x/self.spriteB.contentSize.width , self.imageAnchorB.y / self.spriteB.contentSize.height  );
	
	self.contentSize = self.spriteA.contentSize;
	self.position=ccp(0, 0);
	self.constraint = [joint.chipmunkObjects objectAtIndex:0];
	self.rotation=0;
	return self;
}
- (void) dealloc
{
	[self.spriteA removeFromParent];
	self.spriteA = nil;
	[self.spriteB removeFromParent];
	self.spriteB = nil;
	
	self.layerName = nil;
	
	[super dealloc];
}

- (void) draw
{

	self.spriteA.position =	cpBodyLocal2World(self.constraint.bodyA.body, self.constraint.anchr1);
	self.spriteB.position = cpBodyLocal2World(self.constraint.bodyB.body, self.constraint.anchr2);
	
	
	CGFloat dX = self.spriteB.position.x - self.spriteA.position.x;
	CGFloat dY = self.spriteA.position.y - self.spriteB.position.y;
	
	CGFloat tang = atan2(dY, dX)*180.0/M_PI;
	self.spriteA.rotation=tang;
	
	
	dX = self.spriteA.position.x - self.spriteB.position.x;
	dY = self.spriteB.position.y - self.spriteA.position.y;
	tang = atan2(dY,dX)*180.0/M_PI;
	self.spriteB.rotation = tang;
	
	
	
	CGFloat dis = ccpDistance(self.spriteA.position, self.spriteB.position);
	CGSize cs = self.spriteA.contentSize;
	cs.width = dis+self.spriteA.anchorPointInPoints.x;
	self.spriteA.contentSize = cs;

//	cs = self.spriteB.contentSize;
//	cs.width = dis/2.0+self.spriteB.anchorPointInPoints.x*2;
//	
//	self.spriteB.contentSize=cs;
	self.spriteA.anchorPoint = ccp(  self.imageAnchorA.x/self.spriteA.contentSize.width , self.imageAnchorA.y / self.spriteA.contentSize.height  );
//	self.spriteB.anchorPoint = ccp(  self.imageAnchorB.x/self.spriteB.contentSize.width , self.imageAnchorB.y / self.spriteB.contentSize.height  );
}

#pragma mark -
#pragma mark ChipmunkObject

- (id <NSFastEnumeration>)chipmunkObjects
{
	return nil;
}

- (id) copyWithZone:(NSZone*)zone
{
	return [self retain];
}

@end
