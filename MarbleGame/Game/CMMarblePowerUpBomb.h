//
//  CMMarblePowerUpBomb.h
//  MarbleGame
//
//  Created by Carsten Müller on 9/25/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMMarblePowerUpBase.h"

@class CMSimpleGradient;

@interface CMMarblePowerUpBomb : CMMarblePowerUpBase
@property (nonatomic,retain) CMParticleSystemQuad* particles;
@property (nonatomic,retain) CMSimpleGradient *startColorGradient;
@property (nonatomic,retain) CMSimpleGradient *endColorGradient;

- (void) initDefaults;

@end
