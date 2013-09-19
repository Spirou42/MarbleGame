//
//  MarbleSprite.h
//  CocosTest1
//
//  Created by Carsten Müller on 6/29/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCPhysicsSprite.h"
#import "ObjectiveChipmunk.h"
#import "ChipmunkAutoGeometry.h"
#import "CMObjectSoundProtocol.h"
#import "CMPhysicsSprite.h"
#import "CMMarbleGameDelegate.h"


@interface CMMarbleSprite : CMPhysicsSprite 

@property (nonatomic, retain) NSString *setName;
@property (nonatomic,assign) CGFloat radius;
@property (nonatomic,readonly) NSString* frameName;
@property (nonatomic, readonly) NSString* overlayName;

@property (nonatomic,assign) NSInteger ballIndex;
@property (nonatomic, assign) CGFloat mapLeft,mapBottom,mapRight,mapTop;
@property (nonatomic, assign) BOOL shouldDestroy;
@property (nonatomic, assign) BOOL touchesNeighbour;
@property (nonatomic, assign) NSTimeInterval lastSoundTime;
@property (nonatomic, assign) id<CMMarbleGameDelegate> gameDelegate;

- (id) initWithSpriteFrameName:(NSString*)fn mass:(CGFloat)mass andRadius:(CGFloat)r;
- (id) initWithBallSet:(NSString*)setName ballIndex:(NSInteger)ballIndex mass:(CGFloat)mass andRadius:(CGFloat) r;
- (void) createOverlayTextureRect;
+ (CCSpriteFrame*) spriteFrameForBallSet:(NSString*) setName ballIndex:(NSInteger)ballIndex;
@end
