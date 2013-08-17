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
#import "CMMenuLayer.h"
#import "CMMarbleMainMenuScene.h"
#import "CMMenuLayer.h"
#import "CMMarbleLevelSet.h"
#import "CMMarbleLevel.h"
#import "AppDelegate.h"
#import "CMMarblePlayer.h"
#import "MarbleGameAppDelegate+GameDelegate.h"
@implementation CMMarbleLevelSetScene


- (id) init
{
  self = [super init];
	if (self) {
		CMMarbleLevelSet *set=[CMAppDelegate levelSet];
		CMMenuLayer *menuLayer = [[CMMenuLayer alloc] initWithLabel:@"Level Select"];
		NSInteger levelNumber = 0;
		BOOL levelSelectable = YES;
		for (CMMarbleLevel *level in set.levelList) {
			if (levelNumber > 0) {
				CMMarbleLevel *lastLevel = [set.levelList objectAtIndex:levelNumber-1];
				levelSelectable = [CMAppDelegate player:[CMAppDelegate currentPlayer] hasPlayedLevel:lastLevel.name];
			}
			if (!levelSelectable) {
				break;
			}
			CCControlButton* aButton = [menuLayer addButtonWithTitle:level.name target:self action:@selector(onLevelSelect:)];
			aButton.tag = levelNumber++;
		}
		[menuLayer addButtonWithTitle:@"Back" target:self action:@selector(onEnd:)];
		[self addChild:menuLayer z:1];
//		[self schedule:@selector(onEnd:) interval:5];
	}
  return self;
}

- (void) onLevelSelect:(CCControlButton*) sender
{
	NSInteger level = sender.tag;
	MarbleGameAppDelegate * appDel = CMAppDelegate;
	CMMarblePlayer *player = appDel.currentPlayer;
	
	player.currentLevel = level;
	NSError *error;
	[appDel.managedObjectContext save:&error];
	
//	appDel.currentPlayer = player;
	[self onEnd:0];
}

- (void)onEnd:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CMMarbleMainMenuScene node]];
}
@end
