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
	self.contentRect = CGRectMake(120, 49,800 /*self.contentSize.width*/, 650/*self.contentSize.height*/);
}

- (id) init
{
	self = [super init];
	if (self) {
		[self defaults];
    self.color = ccc3(255,0,0);
//    self.opacity = 255;
	}
	return self;
}

- (CGPoint) positionForNode
{
  CGPoint result = CGPointMake(self.contentRect.origin.x, self.contentRect.origin.y+self.contentRect.size.height);
  NSInteger childCount = self.children.count;
  NSInteger rows = self.children.count / self.gridSize.width;
  NSInteger column = self.children.count % (NSInteger)self.gridSize.width;
  result.x += column* (self.contentRect.size.width / self.gridSize.width);
  result.y -= rows * (self.contentRect.size.height) / self.gridSize.height;
  return result;
}

- (void) addChild:(CCNode *)node z:(NSInteger)z tag:(NSInteger)tag
{
  node.anchorPoint = CGPointMake(0.0, 1.0); // Top Left
  CGPoint p = [self positionForNode];
  node.position = p;
	[super addChild:node z:z tag:tag];
}

@end
