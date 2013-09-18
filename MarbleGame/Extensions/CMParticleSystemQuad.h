//
//  CMParticleSystemQuad.h
//  MarbleGame
//
//  Created by Carsten Müller on 9/18/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCParticleSystemQuad.h"
#import "CCParticleSystem.h"
#import "CMObjectSoundProtocol.h"

@interface CMParticleSystemQuad : CCParticleSystemQuad <CMObjectSoundProtocol>

@property (nonatomic, retain) NSString* soundName;
@end

@interface CMParticleSystem : CCParticleSystem <CMObjectSoundProtocol>
@property(nonatomic,retain) NSString *soundName;
@end