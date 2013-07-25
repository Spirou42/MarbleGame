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

@implementation CMMarbleLevelSetScene


- (id) init
{
  self = [super init];
  
	[self addChild:defaultSceneBackground() z:-1];
  [self addChild:defaultMenuButton()];
  return self;
}

@end
