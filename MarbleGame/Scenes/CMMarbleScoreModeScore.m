//
//  CMMarbleScoreModeScore.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/14/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarbleScoreModeScore.h"
#import "CMMarbleGameDelegate.h"
#import "CMMarbleCollisionCollector.h"
#import "CMMarbleLevelStatistics.h"

@implementation CMMarbleScoreModeScore
@synthesize gameDelegate, comboHits;

- (CGPoint) centerOfMarbles:(id<NSFastEnumeration>) marbleSet
{
  CGPoint result = CGPointZero;
  NSUInteger t = 0;
  for (CALayer* mLayer in marbleSet) {
    result.x += mLayer.position.x;
    result.y += mLayer.position.y;
    t++;
  }
  result.x /=t;
  result.y /=t;
  return result;
}


- (void) scoreWithMarbles:(NSArray *)removedMarbles inLevel:(CMMarbleLevelStatistics *)statistics
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	__block NSUInteger normalHits = 0;
	__block NSUInteger multiHits = 0;
	__block NSMutableArray *oldestHit = [NSMutableArray array];
  
  // collect info
	[removedMarbles enumerateObjectsUsingBlock:
	 ^(NSSet* obj, NSUInteger idx, BOOL* stop){
		 NSTimeInterval k = [[self.gameDelegate collisionCollector] oldestCollisionTime:obj];
		 if (k) {
			 k= now - k;
		 }
		 [oldestHit addObject:[NSNumber numberWithDouble:k]];
		 if ([obj count] == 3) {
			 normalHits ++;
		 }else if ([obj count] > 3) { // multi Hit
			 CGPoint p= [self centerOfMarbles:obj];
			 [self.gameDelegate triggerEffect:kCMMarbleEffect_MultiHit atPosition:p];
			 multiHits ++;
		 }
	 }];
  
  // Combo Hits
  self.comboHits += [removedMarbles count];
	CGFloat comboMultiplier = 0.0f;
	if (self.comboHits>1) {
    NSMutableSet *allMarbles =[NSMutableSet set];
    for (NSSet*t in removedMarbles) {
      [allMarbles addObjectsFromArray:[t allObjects]];
    }
		CGPoint p= [self centerOfMarbles:allMarbles];
		[self.gameDelegate triggerEffect:kCMMarbleEffect_ComboHit atPosition:p];
		comboMultiplier += MARBLE_COMBO_MULTIPLYER;
		self.comboHits -= [removedMarbles count];
	}
	
  if (comboMultiplier <MARBLE_COMBO_MULTIPLYER) {
		comboMultiplier = 1.0f;
	}
  
	// specialMoves
	CGFloat specialMultiplier=1.0;
	NSString * specialString = nil;
  for (NSNumber * delay in oldestHit) {
    CGFloat t = [delay floatValue];
    if (t>0.001) {
			specialMultiplier = MARBLE_SPEZIAL_NICE;
			[self.gameDelegate triggerEffect:kCMMarbleEffect_NICE atPosition:CGPointZero];
      if(t>0.05){
				specialMultiplier = MARBLE_SPEZIAL_RESPECT;
				[self.gameDelegate triggerEffect:kCMMarbleEffect_RESPECT atPosition:CGPointZero];
			}
      if (t>0.10){
				specialMultiplier = MARBLE_SPEZIAL_PERFECT;
				[self.gameDelegate triggerEffect:kCMMarbleEffect_PERFECT atPosition:CGPointZero];
			}
      if (t>0.15){
				specialMultiplier = MARBLE_SPEZIAL_TRICK;
				[self.gameDelegate triggerEffect:kCMMarbleEffect_TRICK atPosition:CGPointZero];
			}
      if (t>0.17) {
				specialMultiplier = MARBLE_SPEZIAL_LUCKY;
				[self.gameDelegate triggerEffect:kCMMarbleEffect_LUCKY atPosition:CGPointZero];
      }
//      self.remarkLabel.visible = YES;
    }
  }
	CGFloat normalScore = (normalHits*MARBLE_HIT_SCORE);
	CGFloat multiScore = (multiHits*MARBLE_HIT_SCORE*MARBLE_MULTY_MUTLIPLYER);
	CGFloat totalScore = (normalScore + multiScore) * specialMultiplier * comboMultiplier;
	NSLog(@"normal: %lu (%f), multi: %lu (%f) combo: %f special: %@ (%f) Total: %f",(unsigned long)normalHits, normalScore, (unsigned long)multiHits,multiScore ,comboMultiplier, specialString,specialMultiplier,totalScore);
	
	statistics.score += totalScore;
}

- (void) marbleDropped:(CMMarbleLevelStatistics *)statistics
{
	self.comboHits = 0;
	statistics.score += MARBLE_THROW_SCORE;
}
- (void) marbleFired
{
	self.comboHits = 0;
}
@end
