//
//  CMMarbleLevel.h
//  Chipmonkey
//
//  Created by Carsten Müller on 6/20/12.
//  Copyright (c) 2012 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CCSprite;
@class CMSimpleShapeReader, CMMarbleLevelSet, CMMarbleRubeReader;

@interface CMMarbleLevel : NSObject
{
//	@protected
//	CCSprite 	*backgroundImage;
//	CCSprite 	*overlayImage;
//	NSString	*name;
//	CMSimpleShapeReader * shapeReader;
//	NSUInteger numberOfMarbles;
//
//	NSString *backgroundFilename;
//	NSString *overlayFilename;
//	NSString *staticBodiesFilename;
//	NSDictionary *scoreLimits;
//	NSDictionary *timeLimits;
//	
//	NSURL		*baseURL;
//	
//	NSString * rubeFileName;

}

@property (retain, nonatomic) NSString *name;															///< levelname
@property (retain, nonatomic) NSString* backgroundFilename;								///< filename of the background image

@property (retain, nonatomic) NSString* overlayFilename;									///< filename of the overlayimage

@property (retain, nonatomic) NSString* staticBodiesFilename;							///< filename of the statics bodies file

@property (retain, nonatomic) CCSprite* backgroundImage;										///< backgroundimage

@property (retain, nonatomic) CCSprite* overlayImage;											///< overlayimage

@property(retain, nonatomic) CMSimpleShapeReader *shapeReader __attribute__((deprecated));						///< shapeReader is depricated now. will be replaced by the RubeReader

@property (assign, nonatomic) NSUInteger numberOfMarbles;									///< initial number of marbles
@property (retain, nonatomic) NSDictionary *scoreLimits, *timeLimits;
@property (readonly, nonatomic) NSInteger amateurScore,professionalScore,masterScore;
@property (readonly, nonatomic) NSTimeInterval amateurTime,professionalTime,masterTime;


@property (nonatomic, retain) NSString *rubeFileName;
@property (nonatomic, retain) CMMarbleRubeReader* rubeReader;
@property (nonatomic, readonly) BOOL isRubeLevel;

///< baseURL for all file operation
@property (retain, nonatomic) NSURL*baseURL;
- (id) initWithDictionary:(NSDictionary*)dict;

- (void) releaseLevelData;

@end
