//
//  CMMarbleGameDelegate.h
//  MarbleGame
//
//  Created by Carsten Müller on 7/28/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
	kCMMarbleEffect_Remove,
	kCMMarbleEffect_Explode,
	kCMMarbleEffect_MultiHit,
	kCMMarbleEffect_ComboHit,
	kCMMarbleEffect_NICE,
	kCMMarbleEffect_RESPECT,
	kCMMarbleEffect_PERFECT,
	kCMMarbleEffect_TRICK,
	kCMMarbleEffect_LUCKY
} CMMarbleEffectType;

@class CMMarbleLevel,CMMarbleCollisionCollector;
@protocol CMMarbleGameDelegate <NSObject>

@required
/**  
 	returns the current level.
 This Method is called by the simulationLayer to retrieve the current level information
 */
- (CMMarbleLevel*) currentLevel;

/**
	returns the index in the of the next marble the player can drop.
 Called by the simulationLayer to provide marbles to the player. Together with <marbleSetName> a valid CCSpriteFrame for the CMMarbleSprite can be retrieved.
 */

- (NSUInteger) marbleIndex;

/**
 returns the name of the current marble set.
 */

- (NSString*) marbleSetName;

/**
 called by the simulationLayer after marbles are removed from the playground.
 the Set contains NSNumbers with marbleIndexs which are currently vissible in the playground.
 */
- (void) imagesOnField:(NSSet*) fieldImages;

/**
 informing the gameDelegate that a Marble was fired by the SimulationLayer
 */
- (void) marbleFiredWithID:(NSUInteger) ballIndex;

/**
 informs the gameDelegate that the player has released a marble
 */
- (void) marbleDroppedWithID:(NSUInteger) ballIndex;

/** 
 called by the simulationLayer during the level initialization
 */
- (void) initializeLevel:(CMMarbleLevel*)level;

/**
 called by the simulationLayer after a physics simulation step is done.
 */
- (void) simulationStepDone:(NSTimeInterval)dt;

/**
 returns the currently active collisionCollector
 */
- (CMMarbleCollisionCollector*) collisionCollector;

/**
 triggers an effect
 */
- (void) triggerEffect:(CMMarbleEffectType)effect atPosition:(CGPoint) position;

- (BOOL) playEffect;
- (CGFloat) soundVolume;

@property (nonatomic, readonly) CGFloat soundVolume;
@property (nonatomic, readonly) BOOL playEffect;

@end
