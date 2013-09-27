//
//  CMMarbleLevel.h
//  Chipmonkey
//
//  Created by Carsten Müller on 6/20/12.
//  Copyright (c) 2012 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CCSprite;
@class CMSimpleShapeReader, CMMarbleLevelSet, CMRubeSceneReader,ChipmunkObject;

@interface CMMarbleLevel : NSObject

@property (retain, nonatomic) NSString *name;															///< levelname
@property (retain, nonatomic) NSString* backgroundFilename;								///< filename of the background image

@property (retain, nonatomic) NSString* overlayFilename;									///< filename of the overlayimage

@property (retain, nonatomic) NSString* staticBodiesFilename;							///< filename of the statics bodies file

@property (retain, nonatomic) CCSprite* backgroundImage;										///< backgroundimage

@property (retain, nonatomic) CCSprite* overlayImage;											///< overlayimage



@property (assign, nonatomic) NSUInteger numberOfMarbles;									///< initial number of marbles
@property (retain, nonatomic) NSDictionary *scoreLimits, *timeLimits;     ///< limits dict for score and time play mode
@property (readonly, nonatomic) NSInteger amateurScore,professionalScore,masterScore; ///< decoded level scores
@property (readonly, nonatomic) NSTimeInterval amateurTime,professionalTime,masterTime; ///< decoded time limits


@property (nonatomic, retain) NSString *rubeFileName;                     ///< name of the associated R.U.B.E. files
@property (nonatomic, retain) CMRubeSceneReader* rubeReader;              ///< instance of the R.U.B.E. reader
@property (nonatomic, readonly) BOOL isRubeLevel;                         ///< marker if this level is a R.U.B.E. level


///< baseURL for all file operation
@property (retain, nonatomic) NSURL*baseURL;


- (id) initWithDictionary:(NSDictionary*)dict;

- (void) releaseLevelData;

// accessors for level data
- (NSArray*) staticObjects __deprecated;
- (NSArray*) worldShapes;										///< all static shapes of the World Object
- (NSArray*) staticSprites;									///< creates and returns a List of all Static Sprites (CMPhysicsSprite) not named "World"
- (NSArray*) dynamicSprites;								///< a list of all dynamic Sprites.
- (NSArray*) constrains;                    ///< a list of all imported constraints

@end
