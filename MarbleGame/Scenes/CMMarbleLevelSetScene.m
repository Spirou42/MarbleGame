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
#import "CMLevelSelectItem.h"
#import "CMMarbleLevelSelectMenu.h"

@interface CMMarbleLevelSetScene ()
@property (nonatomic, retain) CMMarbleLevelSelectMenu* levelMenu;
@end

@implementation CMMarbleLevelSetScene

@synthesize levelMenu=levelMenu_;

- (id) init
{
  self = [super init];
	if (self) {
//    self.levelMenu = [[CMMarbleLevelSelectMenu new] autorelease];

		CMMarbleLevelSet *set=[CMAppDelegate levelSet];
		CMMenuLayer *menuLayer = [[CMMenuLayer alloc] initWithLabel:@"Level Select"];
		menuLayer.defaultButtonSize=CGSizeMake(300, 30);
		CGPoint kk = menuLayer.nextFreeMenuPosition;
		
		kk.y+=40;
		menuLayer.nextFreeMenuPosition=kk;
		NSInteger levelNumber = 0;
		BOOL levelSelectable = YES;
		for (CMMarbleLevel *level in set.levelList) {
			CMLevelSelectItem *item = [CMLevelSelectItem new];
			item.icon = level.icon;
			item.name = level.name;
			item.anchorPoint = CGPointMake(0.50, 0.50);
			item.position =CGPointMake(levelNumber* item.contentSize.width+(item.contentSize.width/2.0), item.contentSize.height/2.0);
			[self.levelMenu addChild:item ];
      [item release];
			
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

- (void) setLevelMenu:(CMMarbleLevelSelectMenu *)levelMenu
{
  if (self->levelMenu_ != levelMenu) {
    if (self->levelMenu_) {
      [self->levelMenu_ removeFromParent];
    }
    [self->levelMenu_ release];
    self->levelMenu_ = [levelMenu retain];
    if (self->levelMenu_) {
      self->levelMenu_.anchorPoint = CGPointMake(0.5, 0.5);
      self->levelMenu_.ignoreAnchorPointForPosition = NO;
      self->levelMenu_.position = CGPointMake(self.contentSize.width/2.0, self.contentSize.height/2.0);
			self->levelMenu_.touchPriority=0;
#if __CC_PLATFORM_MAC
			self->levelMenu_.mousePriority=0;
#endif
      [self addChild:self->levelMenu_ z:10];
    }
  }
}

- (void) dealloc
{
  self.levelMenu = nil;
  [super dealloc];
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
