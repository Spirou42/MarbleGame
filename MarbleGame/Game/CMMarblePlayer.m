//
//  CMMarblePlayer.m
//  MarbleGame
//
//  Created by Carsten Müller on 7/25/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//
// Simple Player object for the MarbleGame

#import "CMMarblePlayer.h"

@implementation CMMarblePlayer
@synthesize currentLevel,scoreMode;

+ (id) playerWithName:(NSString *)userName
{
	id result = [[[[self class] alloc]initWithName:userName]autorelease];
	return result;
}

- (id) init
{
	self = [self initWithName:NSUserName()];
	return self;
}

- (id) initWithName:(NSString*)userName
{
	self = [super init];
	if (self) {
		self.name = userName;
		self.currentLevel = 0;
		self.scoreMode = @"score";
	}
	return self;
}

- (void) dealloc
{
	self.name = nil;
	self.scoreMode = nil;
//	self.levelSetStatistics = nil;
	[super dealloc];
}



#pragma mark -
#pragma mark helper

//- (NSSet*) playedLevelsInSet:(NSString*) setName
//{
//	
//}
//
//- (CMMarbleLevelStatistics*) statisticsForLevel:(NSString *)levelName inSet:(NSString *)setName
//{
//	
//}

#pragma mark -
#pragma mark NSCoding

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		self.name = [aDecoder decodeObjectForKey:@"PlayerName"];
		self.currentLevel = [aDecoder decodeIntegerForKey:@"currentLevel"];
		self.scoreMode = [aDecoder decodeObjectForKey:@"scoreMode"];
		if (!self.scoreMode) {
			self.scoreMode = @"score";
		}
//		self.levelSetStatistics = [aDecoder decodeObjectForKey:@"levelStatistics"];

	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.name forKey:@"PlayerName"];
	[aCoder encodeInteger:self.currentLevel forKey:@"currentLevel"];
	[aCoder encodeObject:self.scoreMode forKey:@"scoreMode"];
}

@end
