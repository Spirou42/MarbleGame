//
//  CMPhysicsSprite.h
//  MarbleGame
//
//  Created by Carsten Müller on 9/14/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCPhysicsSprite.h"
#import "CMObjectSoundProtocol.h"
#import "CMRubeBody.h"

@interface CMPhysicsSprite : CCPhysicsSprite <ChipmunkObject,CMObjectSoundProtocol,NSCopying>

@property (nonatomic,readonly) NSArray *shapes;
@property (nonatomic,retain) CCNode* overlayNode;			// node that is not affected by rotation and is
@property (nonatomic,assign) CGPoint overlayOffset;		///< Offset to the own position
@property (nonatomic, assign) CGPoint originalPosition; ///< originalPosition of the Sprite
@property (nonatomic, assign) CMGameBodyType type;
- (void) addShape:(ChipmunkShape*)someShape;
- (void) addShapes:(id<NSFastEnumeration>)shapes;
@end
