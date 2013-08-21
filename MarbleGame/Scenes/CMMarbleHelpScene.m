//
//  AboutScene.m
//  CocosTest1
//
//  Created by Carsten Müller on 6/29/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarbleHelpScene.h"
#import "CCControlExtension.h"
#import "CMMarbleMainMenuScene.h"
#import "SceneHelper.h"

@implementation CMMarbleHelpScene

- (id) init
{
	self = [super init];
  CGSize winSize = [[CCDirector sharedDirector] winSize];
//  CGPoint pos = CGPointMake(winSize.width/2.0,winSize.height/3.0*2.0);

	if (self != nil) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:DEFAULT_UI_PLIST];
		
    // BACKBUTTON
    CCControlButton *button = standardButtonWithTitle(@"Back");
		[button addTarget:self action:@selector(exitScene:) forControlEvents:CCControlEventTouchUpInside];
		button.position = ccp(900, 50);
		[self addChild:button];

    
	}
  [self addChild:defaultSceneBackground() z:-1];
	return self;
}
- (void) exitScene:(id) sender
{
  [[CCDirector sharedDirector] replaceScene:[CMMarbleMainMenuScene node]];
}

- (void)onEnd:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CMMarbleMainMenuScene node]];
}
@end
