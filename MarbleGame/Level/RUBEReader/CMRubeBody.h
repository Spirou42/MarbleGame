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

typedef enum{
	kGameBody_Undefined = -1,
	kGameBody_World,
	kGameBody_Emitter,
	kGameBody_Respawn,
	kGameBody_Mechanic,
}CMGameBodyType;

@protocol ChipmunkObject;
@class CMPhysicsSprite;

@interface CMRubeBody : NSObject <ChipmunkObject>

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* layerName;
@property (nonatomic, assign) CMRubeBodyType type;
@property (nonatomic, assign) CMGameBodyType gameType;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat angularVelocity;
@property (nonatomic, assign) CGPoint linearVelocity;
@property (nonatomic, assign) CGFloat angularDamping;
@property (nonatomic, assign) CGFloat linearDamping;
@property (nonatomic, assign) CGFloat mass;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) BOOL		fixedRotation;
@property (nonatomic, retain) NSMutableArray *fixtures;
@property (nonatomic, retain) NSMutableArray *attachedImages;
@property (nonatomic, retain) NSString* soundName;
@property (nonatomic, readonly) CMPhysicsSprite* physicsSprite; ///< this returns nil for static bodies
@property (nonatomic, readonly) ChipmunkBody* body;
@property (nonatomic, readonly) NSArray* chipmunkShapes; ///< returns all Attached ChipmunkShapes

- (id) initWithDictionary:(NSDictionary*)dict;

- (id) imageForType:(CMRubeImageType)type;
- (void) attachImage:(CMRubeImage*) rubeImage;
- (NSArray*) chipmunkObjects;

@end
