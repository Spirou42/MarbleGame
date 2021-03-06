//
//  CMMarblePowerUpBallBomb.m
//  MarbleGame
//
//  Created by Carsten Müller on 10/13/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarblePowerUpBallBomb.h"
#import "CMSimpleGradient.h"
#import "SimpleAudioEngine.h"

@implementation CMMarblePowerUpBallBomb

- (void) initDefaults
{
	[super initDefaults];
	self.particles = [self.parentMarble.gameDelegate particleSystemForName:MARBLE_POWERUP_BUBBLE];
	self.startColorGradient = [[[CMSimpleGradient alloc]initWithStartColor:self.particles.startColor
																																endColor:self.particles.endColor]autorelease];

	self.endColorGradient = [[[CMSimpleGradient alloc]initWithStartColor:self.particles.startColor
																															endColor:self.particles.endColor]autorelease];
}

- (id) initWithMarble:(CMMarbleSprite *)marble
{
	self = [super initWithMarble:marble];

	if (self) {

	}
	return self;
}

- (void) performActionFor:(CMMarbleSprite *)marble
{
//	[super performActionFor:marble];

		[marble.gameDelegate triggerEffect:kCMMarblePowerUp_MarbleSource atPosition:marble.position];

}

@end
