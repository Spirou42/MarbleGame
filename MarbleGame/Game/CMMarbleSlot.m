//
//  CMMarbleSlot.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/9/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarbleSlot.h"
#import "CMMarbleSprite.h"
#import "cocos2d.h"

@implementation CMMarbleSlot

- (id) initWithSize:(CGSize)size
{
	self = [super init];
	if (self) {
		self.contentSize = size;
	}
	return self;
}

- (void) addMarbleWithID:(NSUInteger)marbleID
{
	NSString* setName = [[NSUserDefaults standardUserDefaults]stringForKey:@"MarbleSet"];
	CGFloat radius = self.contentSize.height/2.0;
	CCSpriteFrame *spriteFrame = [CMMarbleSprite spriteFrameForBallSet:setName ballIndex:marbleID];
	CMMarbleSprite *marbleSprite = [[CMMarbleSprite alloc] initWithBallSet:setName ballIndex:marbleID mass:5.0 andRadius:radius];
	[marbleSprite createOverlayTextureRect];
	CGFloat myHeight = self.contentSize.height;
	CGFloat scaleFactor;
	scaleFactor = myHeight / marbleSprite.contentSize.height;
	marbleSprite.scale = scaleFactor;
	marbleSprite.anchorPoint = CGPointMake(0.5, 0.5);

	CGPoint startPos = CGPointMake(self.contentSize.width - radius, radius);
	
	NSUInteger marbleCount = self.children.count;
	CGPoint endPos = CGPointMake(marbleCount*self.contentSize.height+radius, radius);
	marbleSprite.position = startPos;
	[self addChild:marbleSprite];
	CGFloat difTime = 0;
	if (marbleCount) {
		difTime = marbleCount*(DEFAULT_MARBLE_SLOT_MOVE_TIME / 9.0f);
	}
	id moveAction = [CCMoveTo actionWithDuration:DEFAULT_MARBLE_SLOT_MOVE_TIME-(difTime) position:endPos];
	[marbleSprite runAction:moveAction];
	
}
//- (void) draw
//{
//	ccDrawColor4F(0.2, 0.9, 0.1, 0.5);
//	glLineWidth(1.8);
//	ccDrawRect(ccp(0, 0), ccp(self.contentSize.width, self.contentSize.height));
//}
@end
