//
//  CMMarblePowerProtocol.h
//  MarbleGame
//
//  Created by Carsten Müller on 9/25/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CMParticleSystemQuad.h"
#import "CMMarbleSprite.h"


//@class CMMarbleSprite;
@protocol CMMarblePowerProtocol <NSObject>

// the particle system used to visualize the powerUp
@property (nonatomic, readonly) CMParticleSystemQuad* particleEffect;

// the marble the PowerUp is attached to;
@property (nonatomic, assign) CMMarbleSprite* parentMarble;

/// the time the action/effect is active
@property (nonatomic, assign) NSTimeInterval activeTime;
/// the remaining time till the effect gets removed / inactive
@property (nonatomic, readonly) NSTimeInterval remainingTime;

@property (nonatomic,readonly) CGFloat scoreValue;
@property (nonatomic,readonly) NSTimeInterval timeValue;

/// the action trigger 
- (void) performActionFor:(CMMarbleSprite*)marble;

/// cald by the marble to trigger position update etc. for the attached particles
- (void) update;
@end
