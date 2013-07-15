//
//  CMSimpleShapeReader.h
//  Chipmonkey
//
//  Created by Carsten Müller on 6/12/12.
//  Copyright (c) 2012 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMSimpleShapeReader : NSObject
{
	@protected
	NSMutableArray *shapes;
	
}

@property (retain, nonatomic) NSMutableArray *shapes;

- (id) initWithContentsOfURL:(NSURL*) fileURL;
- (id) initWithContentsOfFile:(NSString*) filePath;
@end
