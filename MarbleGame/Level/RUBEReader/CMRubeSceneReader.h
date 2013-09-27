//
//  CMMarbleRubeReader.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMRubeBody.h"
@protocol ChipmunkObject;
@class CMRubeBody, CMRubeImage;
@interface CMRubeSceneReader : NSObject <ChipmunkObject>
{
	@protected
	NSMutableArray *_bodies;				///< store for RUBE bodies
	NSMutableArray *_images;				///< store for RUBE images
	NSMutableArray *_joints;				///< store for RUBE joints

	// World parameters
	CGPoint							_gravity;				///< gravity vector for this world
}

@property (retain, nonatomic) NSMutableArray *bodies;
@property (retain, nonatomic) NSMutableArray *images;
@property (retain, nonatomic) NSMutableArray *joints;
@property (assign, nonatomic) CGPoint gravity;
@property (readonly, nonatomic) NSArray* staticBodies;        ///< returns an iteratable of all static bodies in the rube file.
@property (readonly, nonatomic) NSArray* staticShapes;        ///< returns an iteratable of all static shapes in the rube file. Static shapes are shapes attached to any static body. The shapes are NOT detached from the current body!
@property (readonly, nonatomic) NSArray* staticChipmunkObjects;
@property (readonly, nonatomic) NSArray* dynamicBodies;				///< returns an iteratable of all dynamic bodies in the rube-file.
- (id) initWithContentsOfURL:(NSURL*) fileURL;
- (id) initWithContentsOfFile:(NSString*) filePath;

- (CMRubeBody*) bodyWithName:(NSString*) name;
- (NSArray*) bodiesOfType:(CMRubeBodyType) bType;
- (NSArray*) bodiesOfGameType:(CMGameBodyType)bType;
- (CMRubeImage*) imageWithName:(NSString*) name;

@end

CGPoint pointFromRUBEPoint(NSDictionary* dict);
NSArray* pointsFromRUBEPointArray(NSDictionary* dict);
NSDictionary* customPropertiesFrom(NSArray* customArray);