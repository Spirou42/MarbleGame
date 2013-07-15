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

@implementation CMMarbleSettingsScene
@synthesize popupButton;



- (void) marbleSetChanged:(id) sender
{
  NSString *label = [(CCControlPopupButton*)sender selectedLabel].string;
  [[NSUserDefaults standardUserDefaults] setObject:label forKey:@"MarbleSet"];
}

- (id) init
{
	self = [super init];
	if (self != nil) {

		CGSize winSize = [[CCDirector sharedDirector] winSize];

		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Settings" fontName:DEFAULT_MENU_FONT fontSize:DEFAULT_MENU_FONT_SIZE];
		label.color=DEFAULT_MENU_TITLE_COLOR;
		CGPoint menuPosition = ccp(winSize.width/2.0, winSize.height/3.0*2.0);
		label.position = ccp(winSize.width/2.0, winSize.height-label.contentSize.height );
		CGPoint position = menuPosition;
//    position.y -=15;
		[self addChild:label];
    
//    position.y -= label.contentSize.height;

		// marble set
		label = [CCLabelTTF labelWithString:@"Marbleset:" fontName:DEFAULT_MENU_FONT fontSize:DEFAULT_MENU_FONT_SIZE];
		label.color=DEFAULT_MENU_TITLE_COLOR;
		label.anchorPoint=ccp(1.0, 0.5);
		label.position=ccp(position.x-80, position.y);
		[self addChild:label];
    //POPUP Button
    NSArray *t = [(MarbleGameAppDelegate*)[NSApp delegate] marbleSets];
    NSString *marbleSet =[[NSUserDefaults standardUserDefaults]stringForKey:@"MarbleSet"];
    NSInteger i = [t indexOfObject:marbleSet];

    CCControlPopupButton* popB =  [CCControlPopupButton popupButtonWithLabels:t selected:i];  // [self popupWithLabels:t selected:i];
    popB.position = position;
    [self addChild:popB];
    [popB addTarget:self action:@selector(marbleSetChanged:) forControlEvents:CCControlEventValueChanged];
		position.y -= popB.contentSize.height;

		
		
		// marble size
		
		
		
		

    // BACKBUTTON
    CCControlButton *button = standardButtonWithTitle(@"Back");
		[button addTarget:self action:@selector(exitScene:) forControlEvents:CCControlEventTouchUpInside];
		position.y -=38;
		button.position = ccp(900, 50);
		[self addChild:button];

		position.y -=38;
		
    
		[self addChild:defaultSceneBackground() z:-1];
		self.opacity=0.0;
		self.cascadeOpacityEnabled=NO;
    self.popupButton=popB;
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
