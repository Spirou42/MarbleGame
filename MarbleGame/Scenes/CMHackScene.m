//
//  CMHackScene.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/20/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMHackScene.h"
#import "CCControlExtension.h"
#import "CMMarbleMainMenuScene.h"
#import "SceneHelper.h"
#import "CCScrollView.h"
#import "cocos2d.h"

@implementation CMHackScene
- (id) init
{
	self = [super init];
  CGSize winSize = [[CCDirector sharedDirector] winSize];
  //  CGPoint pos = CGPointMake(winSize.width/2.0,winSize.height/3.0*2.0);
  CCSprite *background = defaultSceneBackground();
	if (self != nil) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:DEFAULT_UI_PLIST];
		
    // BACKBUTTON
    CCControlButton *button = standardButtonWithTitle(@"Back");
		[button addTarget:self action:@selector(exitScene:) forControlEvents:CCControlEventTouchUpInside];
		button.position = ccp(900, 50);
//		[self addChild:button];
    
    CCLayerColor *scrollContainer = [CCLayerGradient layerWithColor:ccc4(255, 200, 10, 200) fadingTo:ccc4(255, 200, 200, 200)];
        scrollContainer.contentSize = CGSizeMake(300,800);
//                                     layerWithColor:ccc4(255, 200, 10, 200) width:300 height:750];
    CCScrollView *scrollView = [CCScrollView viewWithViewSize:CGSizeMake(300, 300) container:scrollContainer];
    scrollView.bounces = YES;
//    scrollView.contentSize = CGSizeMake(100,150);
    scrollView.ignoreAnchorPointForPosition = NO;
    scrollView.anchorPoint = ccp(.50, .50);
    scrollView.position = centerOfScreen();

    scrollView.color= ccc3(100, 100, 250);

    scrollContainer.ignoreAnchorPointForPosition = YES;
    scrollContainer.anchorPoint = ccp(.00, 1.0);
//    scrollContainer.contentSize = CGSizeMake(300,800);
//    scrollContainer.position = ccp(0, 300);    //[scrollContainer addChild:scrollView z:1];
    [self addChild:scrollView z:1];
    button.position=ccp(0, 0);
    [scrollView addChild:button];

    scrollView.opacity = 255;
	}
  [self addChild:background z:-1];
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
