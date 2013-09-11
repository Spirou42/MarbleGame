//
//  CMRubeBody.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMRubeImage.h"
typedef enum {
	kRubeBody_static,
	kRubeBody_kinematic,
	kRubeBody_dynamic,
}CMRubeBodyType;

@protocol ChipmunkObject;
@class CCPhysicsSprite;

@interface CMRubeBody : NSObject <ChipmunkObject>

@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) CMRubeBodyType type;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat angularVelocity;
@property (nonatomic, assign) CGPoint linearVelocity;
@property (nonatomic, assign) CGFloat angularDamping;
@property (nonatomic, assign) CGFloat linearDamping;
@property (nonatomic, assign) CGFloat mass;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, retain) NSMutableArray *fixtures;
@property (nonatomic, retain) NSMutableArray *attachedImages;
@property (nonatomic, retain) NSString* soundName;
@property (nonatomic,readonly) CCPhysicsSprite* physicsSprite; ///< this returns nil for static bodies

- (id) initWithDictionary:(NSDictionary*)dict;

- (id) imageForType:(CMRubeImageType)type;
- (void) attachImage:(CMRubeImage*) rubeImage;
- (NSArray*) chipmunkObjects;

@end
