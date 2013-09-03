//
//  StartScene.m
//  CocosTest1
//
//  Created by Carsten Müller on 6/29/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarbleMainMenuScene.h"
#import "CMMarblePlayScene.h"
#import "CMMarbleSettingsScene.h"
#import "CMMarbleHelpScene.h"
#import "CMMarbleLevelSetScene.h"
#import "cocos2d.h"
#import "SceneHelper.h"
#import "CCControlExtension.h"
#import "AppDelegate.h"
#import "MarbleGameAppDelegate+GameDelegate.h"
#import "CCLabelBMFont+CMMarbleRealBounds.h"
#import "CMMenuLayer.h"
#import "CMHackScene.h"

@implementation CMMarbleMainMenuScene


- (id) init
{
	self = [super init];
//	CCLayerColor *parent = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 200) width:winSize.width height:winSize.height];


//  CGPoint pos = menuStartPosition();

	if (self != nil) {
		CGSize buttonSize = DEFAULT_BUTTON_SIZE;
    buttonSize.width += buttonSize.width/3.0*2.0;

		
		CMMenuLayer * menuLayer = [[[CMMenuLayer alloc] initWithLabel:@"Main Menu"] autorelease];
		menuLayer.defaultButtonSize = buttonSize;
		[menuLayer addButtonWithTitle:@"Play" target:self action:@selector(onPlay:)];
		[menuLayer addButtonWithTitle:@"Level Select" target:self action:@selector(onLevelSelect:)];
		[menuLayer addButtonWithTitle:@"Settings" target:self action:@selector(onSettings:)];
		[menuLayer addButtonWithTitle:@"Help" target:self action:@selector(onHelp:)];
    CGPoint newPosition = menuLayer.nextFreeMenuPosition;
    newPosition.y -= 20;
    menuLayer.nextFreeMenuPosition = newPosition;
    [menuLayer addButtonWithTitle:@"Hacktick" target:self action:@selector(hacktickAction:)];

//		menuLayer.opacity=0;
			[self addChild:menuLayer z:2];		


	}

//	CCSprite *plate =mainMenuMenuPlate();
//	plate.position = centerOfScreen();
//	[self addChild:plate z:-1];
	

	return self;
}

- (void)onPlay:(id)sender
{
	NSLog(@"on play");
	[[CCDirector sharedDirector] replaceScene:[CMMarblePlayScene node]];
}

- (void)onSettings:(id)sender
{
	NSLog(@"on settings");
  [[CCDirector sharedDirector] pushScene:[CMMarbleSettingsScene node]];
  //	[[CCDirector sharedDirector] replaceScene:[CMMarbleSettingsScene node]];
}
- (void) onLevelSelect:(id) sender
{
	[[CCDirector sharedDirector] replaceScene:[CMMarbleLevelSetScene node]];
}

- (void)onHelp:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CMMarbleHelpScene node]];
}

- (void) hacktickAction:(id) sender
{
  [[CCDirector sharedDirector] replaceScene:[CMHackScene node]];
}


@end