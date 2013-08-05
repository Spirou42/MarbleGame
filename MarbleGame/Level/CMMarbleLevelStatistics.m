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

- (NSString*) description
{
	NSString *result = [NSString stringWithFormat:@"%@,InLevel: %lu\nRemoved: %lu\ncleared: %@\nimage:%@\n score:%lu\ntime:%f",[super description],(unsigned long)self.marblesInLevel,(unsigned long)self.removedMarbles,clearedMarbles,removedMarblesForImages,(unsigned long)score,time];
	return result;
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

- (void) marbleCleared:(NSNumber *)marbleImage
{
	[self.clearedMarbles addObject:marbleImage];
}

- (void) marbleRemoved:(NSNumber *)removedImage
{
	self.removedMarbles ++;
	
	NSNumber *p = [self.removedMarblesForImages objectForKey:removedImage];
	
	if (!p) {
		p=[NSNumber numberWithInt:0];
	}
	p = [NSNumber numberWithInt:[p intValue]+1];
	
	[self.removedMarblesForImages setObject:p forKey:removedImage];
}

#pragma mark -
#pragma mark NSCoding
- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		self.marblesInLevel = [aDecoder decodeIntegerForKey:@"marblesInLevel"];
		self.removedMarbles = [aDecoder decodeIntegerForKey:@"removedMarbles"];
		self.clearedMarbles = [aDecoder decodeObjectForKey:@"clearedMarbles"];
		self.removedMarblesForImages = [aDecoder decodeObjectForKey:@"removedMarblesForImages"];
		self.score = [aDecoder decodeIntegerForKey:@"score"];
		self.time = [aDecoder decodeFloatForKey:@"time"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeInteger:self.marblesInLevel forKey:@"marblesInLevel"];
	[aCoder encodeInteger:self.removedMarbles forKey:@"removedMarbles"];
	[aCoder encodeObject:self.clearedMarbles forKey:@"clearedMarbles"];
	[aCoder encodeObject:self.removedMarblesForImages forKey:@"removedMarblesForImages"];
	[aCoder encodeInteger:self.score forKey:@"score"];
	[aCoder encodeFloat:self.time forKey:@"time"];
}

@end
