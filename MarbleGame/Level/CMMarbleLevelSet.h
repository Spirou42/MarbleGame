//
//  CMMarbleLevelSet.h
//  Chipmonkey
//
//  Created by Carsten Müller on 6/20/12.
//  Copyright (c) 2012 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMMarbleLevelSet : NSObject
{
	@protected
	NSURL   * baseURL;
	NSArray * levelList;
}
@property (retain, nonatomic) NSURL* baseURL;
@property (retain, nonatomic) NSArray* levelList;

+ (id) levelSetWithURL:(NSURL*) levelSetURL;
- (id) initWithURL:(NSURL*) levelSetURL;
- (void) releaseLevelData;
@end
