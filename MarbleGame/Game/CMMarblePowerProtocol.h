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


@property (nonatomic, readonly) CMParticleSystemQuad* particleEffect;

- (void) performActionFor:(CMMarbleSprite*)marble;
@end
