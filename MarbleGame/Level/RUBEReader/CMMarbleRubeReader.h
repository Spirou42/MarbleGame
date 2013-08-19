//
//  CMMarbleRubeReader.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMMarbleRubeReader : NSObject
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

- (id) initWithContentsOfURL:(NSURL*) fileURL;
- (id) initWithContentsOfFile:(NSString*) filePath;

@end

CGPoint pointFromRUBEPoint(NSDictionary* dict);
NSArray* pointsFRomRUBEPointArray(NSDictionary* dict);