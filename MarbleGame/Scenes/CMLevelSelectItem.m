//
//  CMLevelSelectItem.m
//  MarbleGame
//
//  Created by Carsten Müller on 10/7/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMLevelSelectItem.h"

@interface CMLevelSelectItem ()
@property (nonatomic,retain) CCSprite *overlay;
@property (nonatomic,retain) CCLabelBMFont *label;
@end

@implementation CMLevelSelectItem
@synthesize icon=icon_, overlay=overlay_, name=name_, label=label_;


- (void) defaults
{
	self.overlay = [CCSprite spriteWithFile:@"LevelSelectPlate.png"];
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
	self.icon = nil;
	self.label = nil;
	self.overlay = nil;
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
			CGPoint p = CGPointMake(self.contentSize.width/2.0, self.contentSize.height/2.0+13);
			self->icon_.position = p;
			[self addChild:self->icon_ z:1];
		}
	}
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
		self.label = [self labelForName:self->name_];
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
