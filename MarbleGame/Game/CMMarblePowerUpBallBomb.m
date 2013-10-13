//
//  CMMarblePowerUpBallBomb.m
//  MarbleGame
//
//  Created by Carsten Müller on 10/13/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarblePowerUpBallBomb.h"
#import "CMSimpleGradient.h"
@implementation CMMarblePowerUpBallBomb

- (void) initDefaults
{
	[super initDefaults];
	self.particles = [CMParticleSystemQuad particleWithFile:MARBLE_POWERUP_EXPLODE];
	self.startColorGradient = [[[CMSimpleGradient alloc]initWithStartColor:ccc4f(0.0, 0.3, .50, 1.0)
																																endColor:ccc4f(0.0, 0.8, .80, 1.0)]autorelease];
	
	self.endColorGradient = [[[CMSimpleGradient alloc]initWithStartColor:ccc4f(0.60, 0.60, .40, 1.0)
																															endColor:ccc4f(0.60, 0.60, .40, 1.0)]autorelease];

}

- (id) init
{
	self = [super init];
	if (self) {
	}
	return self;
}

- (void) performActionFor:(CMMarbleSprite *)marble
{
//	[super performActionFor:marble];
	if (POWER_UP_EXPLOSION_BEARING) {
		[marble.gameDelegate triggerEffect:kCMMarblePowerUp_MarbleSource atPosition:marble.position];
	}
}


@end
