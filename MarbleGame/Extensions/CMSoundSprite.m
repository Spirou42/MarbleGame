//
//  CMSoundSprite.m
//  MarbleGame
//
//  Created by Carsten Müller on 9/23/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMSoundSprite.h"

@implementation CMSoundSprite

@synthesize soundName = soundName_, gameDelegate = gameDelegate_;

- (void) dealloc
{
	self.soundName = nil;
	self.gameDelegate = nil;
	[super dealloc];
}
@end
