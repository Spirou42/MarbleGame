//
//  CMPhysicsSprite.h
//  MarbleGame
//
//  Created by Carsten Müller on 9/14/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCPhysicsSprite.h"
#import "CMObjectSoundProtocol.h"

@interface CMPhysicsSprite : CCPhysicsSprite <ChipmunkObject,CMObjectSoundProtocol,NSCopying>

@property (nonatomic,readonly) NSArray *shapes;

- (void) addShape:(ChipmunkShape*)someShape;
- (void) addShapes:(id<NSFastEnumeration>)shapes;
@end
