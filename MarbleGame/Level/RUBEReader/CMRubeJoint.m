//
//  CMRubeJoint.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMRubeJoint.h"
#import "CMRubeSceneReader.h"
#import "CMRubeBody.h"

@interface CMRubeJoint ()
@property (nonatomic, retain) NSMutableArray *cachedChipmunkObjects;
@property (nonatomic, assign) CMRubeBody* bodyA, *bodyB;
@end

@implementation CMRubeJoint
@synthesize name = name_, type=type_, anchorA = anchorA_, anchorB = anchorB_, bodyAIndex = bodyAIndex_, bodyBIndex = bodyBIndex_,
collideConnected = collideConnected_, enableMotor=enableMotor_, jointSpeed = jointSpeed_, lowerLimit = lowerLimit_, upperLimit = upperLimit_,
maxMotorSpeed = maxMotorSpeed_, maxMotorTorque = maxMotorTorque_, dampingRatio = dampingRatio_, frequency = frequency_, length = length_,
localAxisA = localAxisA_, refAngle = refAngle_, springDampingRatio = springDampingRatio_, springFrequency = springFrequency_,
maxForce = maxForce_,maxLength = maxLength_,maxTorque = maxTorque_,correctionFactor = correctionFactor_, cachedChipmunkObjects = cachedChipmunkObjects_,
bodyA = bodyA_, bodyB = bodyB_, enableLimit = enableLimit_,motorSpeed = motorSpeed_;

- (void) initDefaults
{
	self.name = nil;
	self.cachedChipmunkObjects = nil;
	self.bodyA = nil;
	self.bodyB = nil;
}

- (void) initializeCustomProperties:(NSDictionary*)dict
{
	
}

- (CMRubeJointType) typeForName:(NSString*) name
{
	NSArray *k = @[ @"revolute", @"distance", @"prismatic",@"wheel",@"rope",@"motor",@"weld",@"friction"];
	for (NSUInteger p = 0;p<k.count;p++) {
    if ([[k objectAtIndex:p] isEqualToString:name]) {
			return (CMRubeJointType) p;
		}
	}
	return kRubeJoint_Undefined;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
	return [self initWithDictionary:dict andBodies:nil];
}

- (id) initWithDictionary:(NSDictionary *)dict andBodies:(NSArray*) bodies
{
	self = [super init];
	if (self) {
		[self initDefaults];
		self.name = [dict objectForKey:@"name"];
		self.type = [self typeForName:[dict objectForKey:@"type"]];
		
		self.anchorA = pointFromRUBEPoint([dict objectForKey:@"anchorA"]);
		self.anchorB = pointFromRUBEPoint([dict objectForKey:@"anchorB"]);
		self.bodyAIndex = [[dict objectForKey:@"bodyA"]integerValue];
		self.bodyBIndex = [[dict objectForKey:@"bodyB"]integerValue];
		self.collideConnected = [[dict objectForKey:@"collideConnected"]boolValue];

		//revolute
		self.enableMotor = [[dict objectForKey:@"enableMotor"]boolValue];
		self.motorSpeed = [[dict objectForKey:@"motorSpeed"]floatValue];
		self.enableLimit = [[dict objectForKey:@"enableLimit"]boolValue];
		self.jointSpeed = [[dict objectForKey:@"jointSpeed"]floatValue];
		self.lowerLimit =[[dict objectForKey:@"lowerLimit"]floatValue];
		self.upperLimit =[[dict objectForKey:@"upperLimit"]floatValue];
		self.maxMotorSpeed = [[dict objectForKey:@"macMotorSpeed"]floatValue];
		self.maxMotorTorque = [[dict objectForKey:@"maxMotorTorque"]floatValue];
		//Distance
		self.dampingRatio = [[dict objectForKey:@"dampingRatio"]floatValue];
		self.frequency = [[dict objectForKey:@"frequency"]floatValue];
		self.length = [[dict objectForKey:@"length"]floatValue];
		//Prismatic
		self.localAxisA = pointFromRUBEPoint([dict objectForKey:@"localAxisA"]);
		self.refAngle = [[dict objectForKey:@"refAngle"]floatValue];
		//Wheel
		self.springDampingRatio = [[dict objectForKey:@"springDampingRatio"]floatValue];
		self.springFrequency = [[dict objectForKey:@"springFrequency"]floatValue];
		//Rope
		self.maxLength = [[dict objectForKey:@"maxLength"]floatValue];
		//Motor
		self.maxTorque = [[dict objectForKey:@"maxTorque"]floatValue];
		self.maxForce = [[dict objectForKey:@"maxForce"]floatValue];
		self.correctionFactor = [[dict objectForKey:@"correctionFactor"]floatValue];
		[self initializeCustomProperties:customPropertiesFrom([dict objectForKey:@"customProperties"])];
		if (bodies) {
			self.bodyA = [bodies objectAtIndex:self.bodyAIndex];
			self.bodyB = [bodies objectAtIndex:self.bodyBIndex];
		}
	}
	return self;
}

- (NSArray*) revoluteChipmunk
{
	if (!self.bodyA && !self.bodyB) {
		return nil;
	}
	if (!self.cachedChipmunkObjects) {
		if (self.enableLimit) {
			//			ChipmunkRotaryLimitJoint *k = [ChipmunkRotaryLimitJoint rotaryLimitJointWithBodyA:self.bodyA.body bodyB:self.bodyB.body min:self.lowerLimit max:self.upperLimit];
		}else{
			ChipmunkPivotJoint *k = [ChipmunkPivotJoint pivotJointWithBodyA:self.bodyA.body bodyB:self.bodyB.body anchr1:self.anchorA anchr2:self.anchorB];
			//			ChipmunkPinJoint *k = [ChipmunkPinJoint pinJointWithBodyA:self.bodyA.body bodyB:self.bodyB.body anchr1:self.anchorA anchr2:self.anchorB];
			//			k.dist = 0.0;
			k.errorBias = pow(1.0-0.5, 800);
			//			k.errorBias = INFINITY;
			//			k.maxBias = INFINITY;

			if (self.enableMotor) {
				ChipmunkSimpleMotor *m = [ChipmunkSimpleMotor simpleMotorWithBodyA:self.bodyA.body bodyB:self.bodyB.body rate:-self.motorSpeed];
//				m.maxForce = self.maxMotorTorque;
				self.cachedChipmunkObjects = [NSMutableArray arrayWithObjects:k,m, nil];
			}else{
				self.cachedChipmunkObjects = [NSMutableArray arrayWithObject:k];
			}
		}
	}
	return self.cachedChipmunkObjects;
}

- (NSArray*) distanceChipmunk
{
	if (!self.bodyA && !self.bodyB) {
		return nil;
	}

	return self.cachedChipmunkObjects;
}

- (NSArray*) prismaticChipmunk
{
	if (!self.bodyA && !self.bodyB) {
		return nil;
	}

	return self.cachedChipmunkObjects;
}

- (NSArray*) wheelChipmunk
{
	if (!self.bodyA && !self.bodyB) {
		return nil;
	}

	return self.cachedChipmunkObjects;
}

- (NSArray*) ropeChipmunk
{
	if (!self.bodyA && !self.bodyB) {
		return nil;
	}

	return self.cachedChipmunkObjects;
}

- (NSArray*) motorChipmunk
{
	if (!self.bodyA && !self.bodyB) {
		return nil;
	}

	return self.cachedChipmunkObjects;
}

- (NSArray*) weldChipmunk
{
	if (!self.bodyA && !self.bodyB) {
		return nil;
	}

	return  self.cachedChipmunkObjects;
}
- (NSArray*) frictionChipmunk
{
	if (!self.bodyA && !self.bodyB) {
		return nil;
	}

	return self.cachedChipmunkObjects;
}

- (NSArray*) chipmunkObjects
{
	NSMutableArray * result = [NSMutableArray array];
	switch (self.type) {
		case kRubeJoint_Revolute:
			[result addObjectsFromArray:[self revoluteChipmunk]];
			break;
		case kRubeJoint_Distance:
			[result addObjectsFromArray:[self distanceChipmunk]];
			break;
		case kRubeJoint_Prismatic:
			[result addObjectsFromArray:[self prismaticChipmunk]];
			break;
		case kRubeJoint_Wheel:
			[result addObjectsFromArray:[self wheelChipmunk]];
			break;
		case kRubeJoint_Rope:
			[result addObjectsFromArray:[self ropeChipmunk]];
			break;
		case kRubeJoint_Motor:
			[result addObjectsFromArray:[self motorChipmunk]];
			break;
		case kRubeJoint_Weld:
			[result addObjectsFromArray:[self weldChipmunk]];
			break;
		case kRubeJoint_Friction:
			[result addObjectsFromArray:[self frictionChipmunk]];
			break;
		default:
			break;
	}
	return result;
}

@end
