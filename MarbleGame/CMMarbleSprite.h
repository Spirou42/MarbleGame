//
//  MarbleSprite.h
//  CocosTest1
//
//  Created by Carsten Müller on 6/29/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCPhysicsSprite.h"
#import "ObjectiveChipmunk.h"

@interface CMMarbleSprite : CCPhysicsSprite <ChipmunkObject,NSCopying>
{
	@protected	
	ChipmunkShape 			*shape;
	CGFloat 						radius;
//	NSString						*frameName;
	NSString 						*setName;
	NSInteger						ballIndex;
}


@property (nonatomic,retain) ChipmunkShape *shape;
@property (nonatomic,assign) CGFloat radius;
@property (nonatomic,readonly) NSString* frameName;
@property (nonatomic, readonly) NSString* overlayName;
@property (nonatomic,retain) NSString* setName;
@property (nonatomic,assign) NSInteger ballIndex;
- (id) initWithSpriteFrameName:(NSString*)fn mass:(CGFloat)mass andRadius:(CGFloat)r;
- (id) initWithBallSet:(NSString*)setName ballIndex:(NSInteger)ballIndex mass:(CGFloat)mass andRadius:(CGFloat) r;
- (void) createOverlayChild;
@end
