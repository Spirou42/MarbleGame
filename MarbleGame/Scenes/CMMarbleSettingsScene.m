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
#import "CMMarblePlayer.h"
#import "CMMPSettings.h"
#import "MarbleGameAppDelegate+GameDelegate.h"
#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"

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

- (void) musicSliderChanged:(CCControlSlider*) sender
{
  NSLog(@"music: %f",sender.value);
  MarbleGameAppDelegate * appDel = CMAppDelegate;
	CMMarblePlayer *player = appDel.currentPlayer;

  if ((player.settings.musicVolume<0.01f) && (sender.value>=0.01f)) {
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
  }
  if (sender.value <0.01) {
    [[SimpleAudioEngine sharedEngine]stopBackgroundMusic];
  }else{
    [[SimpleAudioEngine sharedEngine]setBackgroundMusicVolume:sender.value];
  }
    player.settings.musicVolume = sender.value;
}

- (void) soundSliderChanged:(CCControlSlider*)sender
{
  static NSTimeInterval lastSoundTime =0;
  NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
  NSLog(@"sound: %f",sender.value);
  MarbleGameAppDelegate * appDel = CMAppDelegate;
	CMMarblePlayer *player = appDel.currentPlayer;
  player.settings.soundVolume = sender.value;
  [[SimpleAudioEngine sharedEngine]setEffectsVolume:sender.value];
  if ((currentTime - lastSoundTime) > .8) {
    lastSoundTime = currentTime;
      [[SimpleAudioEngine sharedEngine] playEffect:DEFAULT_MARBLE_KLICK];
  }
}


- (id) init
{
	self = [super init];
	if (self != nil) {
    MarbleGameAppDelegate * appDel = CMAppDelegate;
    CMMarblePlayer *player = appDel.currentPlayer;

		CMMenuLayer *menuLayer = [[[CMMenuLayer alloc] initWithLabel:@"Settings"]autorelease];
    [self addChild:menuLayer];

    CGPoint k = menuLayer.nextFreeMenuPosition;
    k.x-=70;
    menuLayer.nextFreeMenuPosition = k;
		// create a Popup Button with label
		CGSize menuSize = menuLayer.backgroundSprite.contentSize;

		CGSize buttonSize = menuLayer.defaultButtonSize;
		CCControlPopupButton *popUp = [self createMarbleSetPopUp];

		CCNode<CCLabelProtocol,CCRGBAProtocol>* label = defaultButtonTitle(@"MarbleSet:");
		label.anchorPoint = ccp(1.0, 0.5);
    [menuLayer addLeftNode:label z:1 right:popUp z:10];

    label = defaultButtonTitle(@"Effects:");
    CCControlSlider* effectsSlider = defaultGreenSlider();
    effectsSlider.value = player.settings.soundVolume;
    [effectsSlider addTarget:self action:@selector(soundSliderChanged:) forControlEvents:CCControlEventValueChanged];

    [menuLayer addLeftNode:label z:3 right:effectsSlider z:1];


    label = defaultButtonTitle(@"Music:");
    CCControlSlider* musicSlider = defaultGreenSlider();
    musicSlider.value = player.settings.musicVolume;
    [musicSlider addTarget:self action:@selector(musicSliderChanged:) forControlEvents:CCControlEventValueChanged];
    [menuLayer addLeftNode:label z:3 right:musicSlider z:1];
    
    k=menuLayer.nextFreeMenuPosition;
    k.x+=70;
    k.y = 60;
    menuLayer.nextFreeMenuPosition=k;
		[menuLayer addButtonWithTitle:@"Back" target:self action:@selector(exitScene:)];
		
	}
	return self;
}

- (void) exitScene:(id) sender
{
  NSError *error;
  [[CMAppDelegate managedObjectContext] save:&error];
  [[CCDirector sharedDirector]popScene];
}
- (void)onEnd:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CMMarbleMainMenuScene node]];
}
@end
