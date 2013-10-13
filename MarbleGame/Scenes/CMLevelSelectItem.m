//
//  CMLevelSelectItem.m
//  MarbleGame
//
//  Created by Carsten Müller on 10/7/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMLevelSelectItem.h"
#import "cocos2d.h"

@interface CMLevelSelectItem ()
@property (nonatomic,retain) CCSprite *overlay;
@property (nonatomic,retain) CCLabelBMFont *label;
@property (nonatomic,retain) CCSprite *starOverlay;
@property (nonatomic,retain) CCSprite *playOverlay;
@end

@implementation CMLevelSelectItem
@synthesize icon=icon_, overlay=overlay_, name=name_, label=label_, levelState = levelState_, starOverlay = starOverlay_, playOverlay=playOverlay_;


- (void) defaults
{
	self.overlay = [CCSprite spriteWithFile:@"LevelSelectPlate.png"];
	self.icon = [CCSprite spriteWithFile:@"LevelIcon-Default.png"];
	self.ignoreAnchorPointForPosition = NO;
	
}

- (id) init
{
	self = [super init];
	if (self) {
		[self defaults];
	}
	return self;
}

- (void) dealloc
{
  [self.icon removeFromParent];
	self.icon = nil;

  [self.label removeFromParent];
	self.label = nil;

  [self.overlay removeFromParent];
	self.overlay = nil;
	
	[self.starOverlay removeFromParent];
	self.starOverlay = nil;
	
	[self.playOverlay removeFromParent];
	self.playOverlay = nil;

  
	self.name = nil;
	[super dealloc];
}


#pragma mark - Properties

- (void) setOverlay:(CCSprite *)overlay
{
	if (self->overlay_ != overlay) {
		if (self->overlay_) {
			[self->overlay_ removeFromParent];
		}
		[self->overlay_ release];
		self->overlay_ = [overlay retain];
		self.contentSize = self->overlay_.contentSize;
		self->overlay_.anchorPoint = CGPointMake(0.5, 0.5);
		self->overlay_.position = CGPointMake(self.contentSize.width/2.0, self.contentSize.height/2.0);
		if (self->overlay_) {
			[self addChild:self->overlay_ z:10];
		}
	}
}

- (void) setIcon:(CCSprite *)icon
{
	if (self->icon_ != icon) {
		if (self->icon_) {
			[self->icon_ removeFromParent];
		}
		[self->icon_ release];
		self->icon_ = [icon retain];
		if (self->icon_) {
			self->icon_.anchorPoint = CGPointMake(0.5, 0.5);
			CGPoint p = CGPointMake(self.contentSize.width/2.0, self.contentSize.height/2.0+14);
			self->icon_.position = p;
			[self addChild:self->icon_ z:1];
		}
	}
}
- (void) setStarOverlay:(CCSprite *)starOverlay
{
	if (self->starOverlay_ != starOverlay) {
		if (self->starOverlay_) {
			[self->starOverlay_ removeFromParent];
		}
		[self->starOverlay_ release];
		self->starOverlay_ = [starOverlay retain];
		if (self->starOverlay_) {
			self->starOverlay_.anchorPoint = CGPointMake(0.0, 1.0);
			CGPoint p = CGPointMake(16, self.contentSize.height-16);
			self->starOverlay_.position = p;
			[self addChild:self->starOverlay_ z:2];
		}
	}
}
- (void) setPlayOverlay:(CCSprite *)playOverlay
{
	if (self->playOverlay_ != playOverlay) {
		if (self->playOverlay_) {
			[self->playOverlay_ removeFromParent];
		}
		[self->playOverlay_ release];
		self->playOverlay_ = [playOverlay retain];
		if (self->playOverlay_) {
			self->playOverlay_.anchorPoint = CGPointMake(0.5, 0.5);
			CGPoint p = CGPointMake(self.contentSize.width/2.0, self.contentSize.height/2.0+14);
			self->playOverlay_.position = p;
			[self addChild:self->playOverlay_ z:2];
		}
	}
}


- (void) configureState
{
	if (self.icon == nil) {
		self.icon = [CCSprite spriteWithFile:@"LevelIcon-Default.png"];
	}
	self.playOverlay = [CCSprite spriteWithFile:@"LevelIcon-PlayOverlay.png"];
	switch (self.levelState) {
		case kLevelState_Locked:
			self.icon = [CCSprite spriteWithFile:@"LevelIcon-Locked.png"];
			self.playOverlay = nil;
			break;

		case kLevelState_Unfinished:
			break;

		case kLevelState_Star1:
			self.starOverlay = [CCSprite spriteWithFile:@"Level-Sterne1.png"];
			break;

		case kLevelState_Star2:
			self.starOverlay = [CCSprite spriteWithFile:@"Level-Sterne2.png"];
			break;

		case kLevelState_Star3:
			self.starOverlay = [CCSprite spriteWithFile:@"Level-Sterne3.png"];
			break;

		default:
			break;
	}
}

- (void) onEnter
{
	[self configureState];
	[super onEnter];
}




- (CCLabelBMFont*) labelForName:(NSString*)name
{
	CCLabelBMFont *result = [CCLabelBMFont labelWithString:name fntFile:@"LevelSelect.fnt" width:self.contentSize.width-4 alignment:kCCTextAlignmentCenter];
	return result;
}

- (void) setName:(NSString *)name
{
	if (self->name_ != name) {
		[self->name_ release];
		self->name_ = [name retain];
    if (self->name_) {
      self.label = [self labelForName:self->name_];
    }else{
      self.label = nil;
    }

	}
}

- (void) setLabel:(CCLabelBMFont *)label
{
	if (self->label_ != label) {
		if (self->label_) {
			[self->label_ removeFromParent];
		}
		[self->label_ release];
		self->label_ = [label retain];
		if (self->label_) {
			self->label_.anchorPoint = CGPointMake(0.5, 0.5);
			self->label_.position = CGPointMake((int)(self.contentSize.width/2), (int)(self->label_.contentSize.height));
			[self addChild:self->label_ z:11];
		}
	}
}

@end
