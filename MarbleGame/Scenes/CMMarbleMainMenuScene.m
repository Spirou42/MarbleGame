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

@implementation CMMarbleMainMenuScene

- (id) init
{
	self = [super init];
//	CCLayerColor *parent = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 200) width:winSize.width height:winSize.height];


  CGPoint pos = menuStartPosition();

	if (self != nil) {
    CGSize buttonSize = DEFAULT_BUTTON_SIZE;
    buttonSize.width += buttonSize.width/3.0*2.0;
    buttonSize.height += buttonSize.height/3.0*2.0;

    CCLabelTTF *headlineLabel = (CCLabelTTF*)defaultSceneLabel(@"Main Menu");//[CCLabelTTF labelWithString:@"Main Menu" fontName:DEFAULT_MENU_FONT fontSize:DEFAULT_MENU_FONT_SIZE];
//    headlineLabel.color=DEFAULT_MENU_TITLE_COLOR;
//    headlineLabel.position=pos;
    [self addChild:headlineLabel];
    
    // Play
    pos.y -= headlineLabel.contentSize.height+15;
    CCControlButton *button = standardButtonWithTitle(@"Play");
    button.preferredSize = buttonSize;
    [button addTarget:self action:@selector(onPlay:) forControlEvents:CCControlEventTouchUpInside];
    button.position = pos;
    [self addChild:button];
    
    // Level Select
    pos.y-=button.contentSize.height+5;
    button = standardButtonWithTitle(@"Level Select");
    button.preferredSize = buttonSize;
    [button addTarget:self action:@selector(onLevelSelect:) forControlEvents:CCControlEventTouchUpInside];
    button.position=pos;
    [self addChild:button];

    // Settings
    pos.y-=button.contentSize.height+5;
    button = standardButtonWithTitle(@"Settings");
    button.preferredSize = buttonSize;
    [button addTarget:self action:@selector(onSettings:) forControlEvents:CCControlEventTouchUpInside];
    button.position=pos;
    [self addChild:button];

    // Help
    pos.y -= button.contentSize.height+5;
    button = standardButtonWithTitle(@"Help");
    button.preferredSize = buttonSize;
    [button addTarget:self action:@selector(onHelp:) forControlEvents:CCControlEventTouchUpInside];
    button.position=pos;
    [self addChild:button];

	}
//	[self addChild:parent];
	[self addChild:defaultSceneBackground() z:-1];
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

@end