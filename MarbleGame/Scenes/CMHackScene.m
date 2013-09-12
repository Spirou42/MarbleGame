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

- (void) createSliderIn:(CCNode*) parent
{
	CCSprite *backgroundSprite,*valueSprite,*thumbSprite;
	
	backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"Slider-Track-Normal"];
	valueSprite = [CCSprite spriteWithSpriteFrameName:@"Slider-Track-SelectedGreen"];
	thumbSprite = [CCSprite spriteWithSpriteFrameName:@"Slider-Thumb"];
	
	CCControlSlider *slider  = [CCControlSlider sliderWithBackgroundSprite:backgroundSprite progressSprite:valueSprite thumbSprite:thumbSprite];
	slider.thumbInset = 2;
	CGPoint p = CGPointMake(parent.contentSize.width/2.0, parent.contentSize.height/2.0);
	slider.anchorPoint=CGPointMake(0.5, 0.5);
	slider.position = p;
	[parent addChild:slider z:1];
}

- (id) init
{
	self = [super init];
  CGSize winSize = [[CCDirector sharedDirector] winSize];
  //  CGPoint pos = CGPointMake(winSize.width/2.0,winSize.height/3.0*2.0);
  CCSprite *background = defaultLevelBackground();
	if (self != nil) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:DEFAULT_UI_PLIST];
		
    // BACKBUTTON
    CCControlButton *button = standardButtonWithTitle(@"Back");
		[button addTarget:self action:@selector(exitScene:) forControlEvents:CCControlEventTouchUpInside];
		button.position = ccp(900, 50);
		[self addChild:button];
    
    CCLayerColor *scrollContainer = [CCLayerGradient layerWithColor:ccc4(255, 200, 10, 200) fadingTo:ccc4(255, 200, 200, 200)];
		scrollContainer.contentSize = CGSizeMake(300,800);
    scrollContainer.ignoreAnchorPointForPosition = YES;
    scrollContainer.contentSize = CGSizeMake(300,800);

		
    CCScrollView *scrollView = [CCScrollView viewWithViewSize:CGSizeMake(300, 300) container:scrollContainer];
    scrollView.bounces = YES;

    scrollView.ignoreAnchorPointForPosition = NO;
    scrollView.anchorPoint = ccp(.50, .50);
		CGPoint p = centerOfScreen();
		p.x -= scrollView.contentSize.width;
    scrollView.opacity = 255;
    scrollView.position = p;
    scrollView.color= ccc3(100, 100, 250);

    [self addChild:scrollView z:1];
		
		// create menuPlate
		
		CCSprite *menuPlate = defaultMenuPlate();
		p = centerOfScreen();
		p.x += (menuPlate.contentSize.width / 2.0) - 60;
		menuPlate.position = p;
		[self addChild:menuPlate z:1];
		
		[self createSliderIn:menuPlate];
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
