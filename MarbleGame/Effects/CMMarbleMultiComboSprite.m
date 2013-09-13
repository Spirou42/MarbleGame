//
//  CMMarbleMultiComboSprite.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/7/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarbleMultiComboSprite.h"

@implementation CMMarbleMultiComboSprite

@synthesize soundFileName = soundFileName_;

- (void) removeSelf
{
	[self removeFromParent];
}

- (void) animate
{
	// create some action to

	CGPoint targetPosition = self.position;
	targetPosition.y +=300;
	id actionMove = [CCMoveTo actionWithDuration:DEFAULT_COMBO_MOVE_DURATION position:targetPosition];
	id actionScale = [CCScaleTo actionWithDuration:DEFAULT_COMBO_SCALE_DURATION scale:DEFAULT_COMBO_SCALE_TARGET];
//	id actionFlip = [CCFlipY3D actionWithDuration:DEFAULT_COMBO_MOVE_DURATION/10.0];
//	id d3Action = [CCRepeat actionWithAction:actionFlip times:10];
	id d3ActionTwirl = [CCTwirl actionWithDuration:DEFAULT_COMBO_MOVE_DURATION size:CGSizeMake(4, 4) position:ccp(1024/2, 768/2) twirls:3 amplitude:1];
	id d3ActionLiquid = [CCLiquid actionWithDuration:DEFAULT_COMBO_MOVE_DURATION size:CGSizeMake(64, 64) waves:3 amplitude:6];

	id allActions = [CCSpawn actions:actionMove, d3ActionTwirl, d3ActionLiquid, actionScale, nil];
	id callAction = [CCCallFunc actionWithTarget:self selector:@selector(removeSelf)];
	[self runAction:[CCSequence actions:allActions,callAction, nil]];

}

- (void) dealloc
{
	self.soundFileName=nil;
	[super dealloc];
}
@end
