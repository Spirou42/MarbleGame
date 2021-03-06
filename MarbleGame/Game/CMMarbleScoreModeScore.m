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
#import "CMMPLevelStat.h"
#import "CMMarbleLevel.h"
#import "CMMarbleSprite.h"
#import "CMMarblePowerProtocol.h"

@interface CMMarbleScoreModeScore ()

@property (nonatomic, assign) CGFloat lastMarbleScore;

@end


@implementation CMMarbleScoreModeScore

@synthesize gameDelegate = gameDelegate_, comboHits = comboHits_,lastMarbleScore = lastMarbleScore_;

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

- (CGFloat) scoreModifiersFor:(id<NSFastEnumeration>) marbleSet
{
  CGFloat k = 0.0;
  for (CMMarbleSprite  * marble in marbleSet) {
    if (marble.marbleAction) {
      k+=marble.marbleAction.scoreValue;
    }
  }
  return k;
}

- (void) scoreWithMarbles:(NSArray *)removedMarbles inLevel:(CMMPLevelStat *)statistics
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	__block NSUInteger normalHits = 0;
	__block NSUInteger multiHits = 0;
	__block NSMutableArray *oldestHit = [NSMutableArray array];
  __block CGPoint hitPosition;
  __block CGFloat powerUpModifier = 0.0;
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
			 hitPosition= [self centerOfMarbles:obj];
			 [self.gameDelegate triggerEffect:kCMMarbleEffect_Remove atPosition:hitPosition];
//      [self.gameDelegate triggerEffect:kCMMarbleEffect_ComboHit atPosition:hitPosition];
		 }else if ([obj count] > 3) { // multi Hit
			 hitPosition= [self centerOfMarbles:obj];
       [self.gameDelegate triggerEffect:kCMMarbleEffect_Explode atPosition:hitPosition];
			 [self.gameDelegate triggerEffect:kCMMarbleEffect_MultiHit atPosition:hitPosition];
			 multiHits ++;
		 }
     powerUpModifier+=[self scoreModifiersFor:obj];
	 }];
  
  // Combo Hits
  self.comboHits += [removedMarbles count];
	CGFloat comboMultiplier = 0.0f;
	if (self.comboHits>1) {
    NSMutableSet *allMarbles =[NSMutableSet set];
    for (NSSet*t in removedMarbles) {
      [allMarbles addObjectsFromArray:[t allObjects]];
    }
		hitPosition= [self centerOfMarbles:allMarbles];

    [self.gameDelegate triggerEffect:kCMMarbleEffect_Explode atPosition:hitPosition];
    [self.gameDelegate triggerEffect:kCMMarbleEffect_ComboHit atPosition:hitPosition];
		comboMultiplier = MARBLE_COMBO_MULTIPLYER * (self.comboHits -1);
    NSLog(@"ComboHits: %ld" ,(long)self.comboHits);
//		self.comboHits -= [removedMarbles count];
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
  if (powerUpModifier == 0.0) {
    powerUpModifier = 1.0;
  }
	CGFloat normalScore = (normalHits*MARBLE_HIT_SCORE);
	CGFloat multiScore = (multiHits*MARBLE_HIT_SCORE*MARBLE_MULTY_MUTLIPLYER);
	CGFloat totalScore = (normalScore + multiScore) * specialMultiplier * comboMultiplier * powerUpModifier;
	self.lastMarbleScore = totalScore;
	[self.gameDelegate triggerEffect:kCMMarbleEffect_Score atPosition:hitPosition];
	self.lastMarbleScore = totalScore;
//	NSLog(@"normal: %lu (%f), multi: %lu (%f) combo: %f special: %@ (%f) Total: %f",(unsigned long)normalHits, normalScore, (unsigned long)multiHits,multiScore ,comboMultiplier, specialString,specialMultiplier,totalScore);
	
	statistics.score += totalScore;
}

- (void) marbleDropped:(CMMPLevelStat *)statistics
{
	self.comboHits = 0;
	statistics.score += MARBLE_THROW_SCORE;
}
- (void) marbleFired
{
	self.comboHits = 0;
}

- (CMMPLevelStat*) betterStatOfOld:(CMMPLevelStat *)oldStat new:(CMMPLevelStat *)newStat
{
	if (!oldStat) {
		return newStat;
	}
	if (!newStat) {
		return oldStat;
	}
	if (![oldStat.scoreMode  isEqualToString:newStat.scoreMode]) {
		return nil;
	}
	
	if (oldStat.score > newStat.score) {
		return oldStat;
	}else if (oldStat.score < newStat.score){
		return newStat;
	}
	// and now for equal scores the better time wins
	if (oldStat.time < newStat.time) {
		return oldStat;
	}else{
		return newStat;
	}
	
}

- (CMMarbleGameLevelStatus) statusOfLevel:(CMMarbleLevel *)level forStats:(CMMPLevelStat *)statistics
{
	if (statistics.score >= level.masterScore) {
		return kCMLevelStatus_Master;
	}else if (statistics.score >= level.professionalScore){
		return kCMLevelStatus_Professional;
	}else if (statistics.score >= level.amateurScore){
		return kCMLevelStatus_Amateure;
	}
	return kCMLevelStatus_Failed;
}

- (CGFloat)lastScore
{
	return self.lastMarbleScore;
}
@end
