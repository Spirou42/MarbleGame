//
//  CMSoundPolyShape.m
//  MarbleGame
//
//  Created by Carsten Müller on 9/11/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMSoundShape.h"

@implementation CMSoundCircleShape
@synthesize soundFileName=soundFileName_;

- (void) initializeDefaults
{
	self.soundFileName = DEFAULT_WALL_KLICK;
}

- (id)initWithBody:(ChipmunkBody *)body radius:(cpFloat)radius offset:(cpVect)offset;
{
	self = [super initWithBody:body radius:radius offset:offset];
	if (self) {
		[self initializeDefaults];
	}
	return self;
}

- (void) dealloc
{
	self.soundFileName = nil;
	[super dealloc];
}
@end



@implementation CMSoundSegmentShape
@synthesize soundFileName=soundFileName_;

- (void) initializeDefaults
{
	self.soundFileName = DEFAULT_WALL_KLICK;
}

- (id)initWithBody:(ChipmunkBody *)body from:(cpVect)a to:(cpVect)b radius:(cpFloat)radius;
{
	self = [super initWithBody:body from:a to:b radius:radius];
	if (self) {
		[self initializeDefaults];
	}
	return self;
}

- (void) dealloc
{
	self.soundFileName = nil;
	[super dealloc];
}
@end


@implementation CMSoundPolyShape
@synthesize soundFileName=soundFileName_;

- (void) initializeDefaults
{
	self.soundFileName = DEFAULT_WALL_KLICK;
}

- (id)initWithBody:(ChipmunkBody *)body count:(int)count verts:(cpVect *)verts offset:(cpVect)offset;
{
	self = [super initWithBody:body count:count verts:verts offset:offset];
	if (self) {
		[self initializeDefaults];
	}
	return self;
}

- (void) dealloc
{
	self.soundFileName = nil;
	[super dealloc];
}
@end
