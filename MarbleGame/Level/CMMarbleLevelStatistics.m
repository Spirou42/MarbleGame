//
//  CMMarbleLevelStatistics.m
//  Chipmonkey
//
//  Created by Carsten Müller on 6/23/12.
//  Copyright (c) 2012 Carsten Müller. All rights reserved.
//

#import "CMMarbleLevelStatistics.h"


@interface CMMarbleLevelStatistics ()
@property (retain, nonatomic) NSMutableArray *clearedMarbles;
@property (retain, nonatomic) NSMutableDictionary *removedMarblesForImages;
@end

@implementation CMMarbleLevelStatistics
@synthesize clearedMarbles, removedMarblesForImages, marblesInLevel, removedMarbles, score, time;

- (void) initDefaults
{
	self.marblesInLevel = 0;
	self.removedMarbles = 0;
	self.clearedMarbles = [NSMutableArray array];
	self.removedMarblesForImages = [NSMutableDictionary dictionary];
	self.score = 0;
	self.time =0.0;
}

- (id) init
{
	if((self = [super init])){
		[self initDefaults];
	}
	return self;
}

- (void) dealloc
{
	self.clearedMarbles = nil;
	self.removedMarblesForImages = nil;
	[super dealloc];
}

#pragma mark - Properties

- (NSDictionary*) removedMarblesPerImage
{
	return self.removedMarblesForImages;
}

- (NSArray*) clearedMarbleImages
{
	return self.clearedMarbles;
}

- (void) setTime:(NSTimeInterval)t
{
	if (self->time != t){
		self->time = t;
	}
}
#pragma mark - methods

- (void) reset
{
	[self initDefaults];
}

- (void) marbleCleared:(CMMarbleSprite *)marbleImage
{
	[self.clearedMarbles addObject:marbleImage];
}

- (void) marbleRemoved:(CMMarbleSprite *)removedImage
{
	self.removedMarbles ++;
	
	NSNumber *p = [self.removedMarblesForImages objectForKey:removedImage];
	
	if (!p) {
		p=[NSNumber numberWithInt:0];
	}
	p = [NSNumber numberWithInt:[p intValue]+1];
	
	[self.removedMarblesForImages setObject:p forKey:removedImage];
}

@end
