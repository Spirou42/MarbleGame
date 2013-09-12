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

		CGSize buttonSize = menuLayer.defaultButtonSize;
		CCControlPopupButton *popUp = [self createMarbleSetPopUp];

		CCNode<CCLabelProtocol,CCRGBAProtocol>* label = defaultButtonTitle(@"MarbleSet");
		label.anchorPoint = ccp(1.0, 0.5);
    [menuLayer addLeftNode:label z:1 right:popUp z:10];
//		[menuLayer addNode:popupButtonLayer z:10];
		[self addChild:menuLayer];


    CGPoint l = menuLayer.nextFreeMenuPosition;

		[menuLayer addButtonWithTitle:@"Back" target:self action:@selector(exitScene:)];
		
	}
	return self;
}

- (void) exitScene:(id) sender
{
  [[CCDirector sharedDirector]popScene];
}
- (void)onEnd:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CMMarbleMainMenuScene node]];
}
@end
