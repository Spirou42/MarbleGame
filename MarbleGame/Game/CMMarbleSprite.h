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

@protocol CMMarblePowerProtocol;

@interface CMMarbleSprite : CMPhysicsSprite 

/** name of the marbleSet*/
@property (nonatomic, retain) NSString *marbleSetName;
/** radius of the marble */
@property (nonatomic,assign) CGFloat radius;
/** name of the currently used CCSpriteFrame */
@property (nonatomic,readonly) NSString* frameName;
/** name of the currently used CCSpriteFrame overlay */
@property (nonatomic, readonly) NSString* overlayName;

/** Image index of the current marble (0-8) */
@property (nonatomic,assign) NSInteger ballIndex;
/** map coordinates for the overlay */
@property (nonatomic, assign) CGFloat mapLeft,mapBottom,mapRight,mapTop;
/** triggers self descrtuction if set to YES */
@property (nonatomic, assign) BOOL shouldDestroy;

/** true if the receiver touches a marble with the same marbleIndex (aka color) */
@property (nonatomic, assign) BOOL touchesNeighbour;
/** timestamp of the last sound effect */
@property (nonatomic, assign) NSTimeInterval lastSoundTime;
/** the game delegate of that marble (the PlayScene) */
@property (nonatomic, assign) id<CMMarbleGameDelegate> gameDelegate;

/** something (not yet specified) to trigger effects and perform some kind of special actions (explosion etc.), The PowerUp Object */
@property (nonatomic, retain) NSObject<CMMarblePowerProtocol> *marbleAction;

- (id) initWithSpriteFrameName:(NSString*)fn mass:(CGFloat)mass andRadius:(CGFloat)r;
- (id) initWithBallSet:(NSString*)setName ballIndex:(NSInteger)ballIndex mass:(CGFloat)mass andRadius:(CGFloat) r;
- (void) createOverlayTextureRect;
+ (CCSpriteFrame*) spriteFrameForBallSet:(NSString*) setName ballIndex:(NSInteger)ballIndex;
@end
