//
//  CMMarbleLevelSetScene.m
//  MarbleGame
//
//  Created by Carsten Müller on 7/25/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarbleLevelSetScene.h"
#import "Cocos2d.h"
#import "SceneHelper.h"
#import "CCControlExtension.h"
#import "CMMenuLayer.h"
#import "CMMarbleMainMenuScene.h"
#import "CMMenuLayer.h"
@implementation CMMarbleLevelSetScene


- (id) init
{
  self = [super init];
	if (self) {

		CMMenuLayer *menuLayer = [[CMMenuLayer alloc] initWithLabel:@"Level Select"];
		[self addChild:menuLayer z:1];
		[self schedule:@selector(onEnd:) interval:5];
	}
  return self;
}


- (void)onEnd:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CMMarbleMainMenuScene node]];
}
@end
