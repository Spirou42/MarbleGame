//
//  CMMableLevelSelectMenu.m
//  MarbleGame
//
//  Created by Carsten Müller on 10/7/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarbleLevelSelectMenu.h"

@implementation CMMarbleLevelSelectMenu
@synthesize contentRect = contentRect_, gridSize=gridSize_;

- (void) defaults
{
	self.contentSize = [[CCDirector sharedDirector]winSize];
	self.gridSize = CGSizeMake(4, 3);
	self.contentRect = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
}

- (id) init
{
	self = [super init];
	if (self) {
		[self defaults];
	}
	return self;
}

- (void) addChild:(CCNode *)node z:(NSInteger)z
{
	[super addChild:node z:z];
}

@end
