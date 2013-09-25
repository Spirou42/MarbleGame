//
//  CMMarblePowerUpBomb.m
//  MarbleGame
//
//  Created by Carsten Müller on 9/25/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarblePowerUpBomb.h"
#import "CMParticleSystemQuad.h"
#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"
@interface CMMarblePowerUpBomb ()
@property (nonatomic,retain) CMParticleSystemQuad* particles;
@end

@implementation CMMarblePowerUpBomb

- (id) init
{
	self = [super init];
	if (self) {
		self.particles = [CMParticleSystemQuad particleWithFile:MARBLE_POWERUP_EXPLODE];
	
	}
	return self;
}

- (void) dealloc
{
	self.particles = nil;
	[super dealloc];
}

- (CMParticleSystemQuad*) particleEffect
{
	return self.particles;
}

- (void) performActionFor:(CMMarbleSprite *)marble
{
//	NSLog(@"A C T I O N");
	ChipmunkSpace *currentSpace = marble.chipmunkBody.space;
	ChipmunkBody* currentBody = marble.chipmunkBody;
	
	CGPoint pos = marble.position;
	
	NSArray *results = [currentSpace nearestPointQueryAll:pos maxDistance:100 layers:CP_ALL_LAYERS group:CP_NO_GROUP];
	for (ChipmunkNearestPointQueryInfo* info in results) {
    ChipmunkBody *body = info.shape.body;
		if (!body.isStatic) {
			CGPoint direction = cpvnormalize( cpvsub(info.point, pos));
			CGPoint impulse = cpvmult(direction, 20000);
			[body applyImpulse:impulse offset:CGPointMake(0, 0)];
		}
	}
	[[SimpleAudioEngine sharedEngine] playEffect:DEFAULT_MARBLE_BOOM];
}
@end
