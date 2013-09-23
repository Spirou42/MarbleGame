//
//  CMScoreSprite.m
//  MarbleGame
//
//  Created by Carsten Müller on 9/23/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMScoreSprite.h"

@implementation CMScoreSprite

- (id) initWithScore:(CGFloat)score
{
	self = [super init];
	NSString* scoreString = [NSString stringWithFormat:@"%ld",(NSInteger)score];
	CCLabelBMFont* scoreLabel = [CCLabelBMFont labelWithString:scoreString fntFile:DEFAULT_SCORE_EFFECT_FONT];

	self.contentSize = scoreLabel.contentSize;
	scoreLabel.anchorPoint = CGPointMake(0.5, .50);
	scoreLabel.position = CGPointMake(self.contentSize.width/2.0,0);
	[self addChild:scoreLabel];
	self.anchorPoint = CGPointMake(0.5, 0.5);
	self.cascadeOpacityEnabled = YES;
	self.scale = 0.25;
	return self;
}
- (void) removeSelf
{
	[self removeFromParent];
}

-(void) onEnterTransitionDidFinish
{
	id actionScale = [CCScaleTo actionWithDuration:DEFAULT_COMBO_MOVE_DURATION/3.0 scale:1];
	id actionFade = [CCFadeOut actionWithDuration:DEFAULT_COMBO_MOVE_DURATION/3.0];
	// all
	id allActions = [CCSpawn actions:actionScale,actionFade,nil];
	id callAction = [CCCallFunc actionWithTarget:self selector:@selector(removeSelf)];
	
	[self runAction:[CCSequence actions:allActions,callAction, nil]];
}

//- (void) draw
//{
//	[super draw];
//	ccDrawColor4F(1.0, 0.8, 0.1, 0.5);
//	glLineWidth(2);
//	ccDrawRect(CGPointMake(0, 0), CGPointMake(self.contentSize.width, self.contentSize.height));
//}
@end
