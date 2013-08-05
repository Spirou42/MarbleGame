//
//  CMMarbleGameDelegate.h
//  MarbleGame
//
//  Created by Carsten Müller on 7/28/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CMMarbleLevel;
@protocol CMMarbleGameDelegate <NSObject>

@required
- (CMMarbleLevel*) currentLevel;
- (NSUInteger) marbleIndex;
- (NSString*) marbleSetName;
- (void) imagesOnField:(NSSet*) fieldImages;

	// called by the game simluation view in case a marble is new in the game

- (void) marbleFiredWithID:(NSUInteger) ballIndex;

- (void) marbleDroppedWithID:(NSUInteger) ballIndex;
@end
