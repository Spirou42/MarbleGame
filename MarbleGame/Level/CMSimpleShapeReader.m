//
//  CMSimpleShapeReader.m
//  Chipmonkey
//
//  Created by Carsten Müller on 6/12/12.
//  Copyright (c) 2012 Carsten Müller. All rights reserved.
//

#import "CMSimpleShapeReader.h"
#import "ObjectiveChipmunk.h"

@implementation CMSimpleShapeReader
@synthesize shapes;

- (NSArray*) createShapeFromArray:(NSArray*) shapeCoordinates inSize:(CGSize) size
{
	NSMutableArray *result = [NSMutableArray array];
	NSUInteger ll =[shapeCoordinates count] ;
	cpVect *vertices = malloc(ll*sizeof(cpVect));
	ll --;
	for (NSUInteger i=0; i<[shapeCoordinates count]; i++) {
		NSString *line = [shapeCoordinates objectAtIndex:i];
		line = [NSString stringWithFormat:@"{%@}",line];
#ifdef __CC_PLATFORM_MAC
    CGPoint p = NSPointToCGPoint(NSPointFromString(line));
#else
    CGPoint p = CGPointFromString(line);
#endif
		
		vertices[ll-i] = p;
//		vertices[ll-i].y = size.height - p.y;
	}
	for (NSUInteger i=0; i<ll; i++) {
		ChipmunkSegmentShape *cs= [ChipmunkSegmentShape segmentWithBody:nil from:vertices[i] to:vertices[i+1] radius:1];
    cs.collisionType = @"borderType";
		cs.friction = 1.0;
		cs.elasticity = 0.51;
		[result addObject:cs];
	}
	
	
	free(vertices);
	return result;
}

- (void) readFileFromURL:(NSURL*) aFile
{
	NSError *fileError = nil;
	NSString *contents = [NSString stringWithContentsOfURL:aFile encoding:NSUTF8StringEncoding error:&fileError];
	NSArray *dataLines = [contents componentsSeparatedByString:@"\n"];

	
	NSUInteger numOfLinesInShape = 0;
	for(NSUInteger i=0;i<[dataLines count];i++){
		NSString *line = [dataLines objectAtIndex:i];		


		if([line hasPrefix:@"*"]){ // start of an shape
			line = [line stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"*"]];
			numOfLinesInShape = (NSUInteger)[line integerValue];
			NSRange aRange = NSMakeRange(i+1, numOfLinesInShape);
			NSArray *shapeArray = [dataLines subarrayWithRange:aRange];
			shapeArray = [self createShapeFromArray:shapeArray inSize:CGSizeMake(1024, 768)];
			if (shapeArray) {
				for (id<ChipmunkObject> obj in shapeArray) {
					[self.shapes addObject:obj];
					
				}

			}
			i+= numOfLinesInShape+1;
		}
	}
}

- (id) initWithContentsOfURL:(NSURL *)fileURL
{
	self.shapes = [NSMutableArray array];
	if((self = [super init])){
		[self readFileFromURL:fileURL];
	}
	return self;
}

- (id) initWithContentsOfFile:(NSString *)filePath
{
	NSURL * fileURL = [NSURL fileURLWithPath:filePath];
	return [self initWithContentsOfURL:fileURL];
}

- (void) dealloc
{
	self.shapes = nil;
	[super dealloc];
}
@end
