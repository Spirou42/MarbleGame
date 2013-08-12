//
//  SettingScene.m
//  CocosTest1
//
//  Created by Carsten Müller on 6/29/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarbleSettingsScene.h"
#import "cocos2d.h"
#import "CMMarbleMainMenuScene.h"
#import "SceneHelper.h"
#import "AppDelegate.h"
#import "CCControlPopupButton.h"
#import "CMMenuLayer.h"
@implementation CMMarbleSettingsScene
@synthesize popupButton;



- (void) marbleSetChanged:(id) sender
{
  NSString *label = [(CCControlPopupButton*)sender selectedLabel].string;
  [[NSUserDefaults standardUserDefaults] setObject:label forKey:@"MarbleSet"];
}

- (CCControlPopupButton*) createMarbleSetPopUp
{
	NSArray *t = [CMAppDelegate marbleSets];
	NSString *marbleSet =[[NSUserDefaults standardUserDefaults]stringForKey:@"MarbleSet"];
	NSInteger i = [t indexOfObject:marbleSet];
	
	CCControlPopupButton* popB =  [CCControlPopupButton popupButtonWithLabels:t selected:i];  // [self popupWithLabels:t selected:i];
	[popB addTarget:self action:@selector(marbleSetChanged:) forControlEvents:CCControlEventValueChanged];
	return popB;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		CMMenuLayer *menuLayer = [[[CMMenuLayer alloc] initWithLabel:@"Settings"]autorelease];
		// create a Popup Button with label
		CGSize menuSize = menuLayer.backgroundSprite.contentSize;
		CCNodeRGBA *popupButtonLayer = [[[CCNodeRGBA alloc] init]autorelease];
		popupButtonLayer.color = ccc3(255,200,10);
//		popupButtonLayer.opacity = 128;
		popupButtonLayer.anchorPoint=ccp(0.5, 0.5);
		popupButtonLayer.contentSize = CGSizeMake(menuSize.width, 50);
		CGPoint buttonPosition = ccp(menuSize.width/2.0, popupButtonLayer.contentSize.height/2.0);
		CGSize buttonSize = menuLayer.defaultButtonSize;
		CCControlPopupButton *popUp = [self createMarbleSetPopUp];
		popUp.position = buttonPosition;
		popUp.contentSize=buttonSize;
		
		CGPoint labelPosition = ccp(buttonPosition.x - popUp.contentSize.width/2.0 - menuLayer.interElementSpacing, popupButtonLayer.contentSize.height/2.0);
		CCNode<CCLabelProtocol,CCRGBAProtocol>* label = defaultButtonTitle(@"MarbleSet");
		label.anchorPoint = ccp(1.0, 0.5);
		label.position = labelPosition;
		[popupButtonLayer addChild:popUp];
		[popupButtonLayer addChild:label];
		popupButtonLayer.contentSize = CGSizeMake(menuSize.width, 50);
		popupButtonLayer.cascadeColorEnabled = NO;
		[popupButtonLayer updateDisplayedColor:ccc3(255, 200, 10)];
		[popupButtonLayer updateDisplayedOpacity:128];
		[menuLayer addNode:popupButtonLayer z:10];
		[self addChild:menuLayer];
		[menuLayer addButtonWithTitle:@"Back" target:self action:@selector(exitScene:)];
		
	}
	return self;
}

- (void) exitScene:(id) sender
{
	NSLog(@"Sender: %@",sender);
  [[CCDirector sharedDirector]popScene];
//		[[CCDirector sharedDirector] replaceScene:[CMMarbleMainMenuScene node]];
}
- (void)onEnd:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CMMarbleMainMenuScene node]];
}
@end
