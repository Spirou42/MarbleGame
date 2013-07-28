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


- (id) init
{
	self = [super init];
	if(self)
	{
		self.name = NSUserName();
		self.levelSetStatistics = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void) dealloc
{
	self.name = nil;
	self.levelSetStatistics = nil;
	[super dealloc];
}



#pragma mark -
#pragma mark helper

- (NSSet*) playedLevelsInSet:(NSString*) setName
{
	
}

- (CMMarbleLevelStatistics*) statisticsForLevel:(NSString *)levelName inSet:(NSString *)setName
{
	
}

#pragma mark -
#pragma mark NSCoding

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		self.name = [aDecoder decodeObjectForKey:@"PlayerName"];
		self.levelSetStatistics = [aDecoder decodeObjectForKey:@"levelStatistics"];

	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.name forKey:@"PlayerName"];
	[aCoder encodeObject:self.levelSetStatistics forKey:@"levelStatistice"];
}

@end
