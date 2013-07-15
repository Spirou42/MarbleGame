//
//  CMMarbleLevelStatistics.h
//  Chipmonkey
//
//  Created by Carsten Müller on 6/23/12.
//  Copyright (c) 2012 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMMarbleSprite.h"

@interface CMMarbleLevelStatistics : NSObject
{
	@protected
	NSUInteger 					marblesInLevel;								///< number of marbles in level
	NSUInteger 					removedMarbles;								///< total number of marbles removed
	NSMutableArray 			*clearedMarbles;							///< UIImages of the cleared marble colors
	NSMutableDictionary	*removedMarblesForImages; 		///< key:= UIImage Value: removed marbles of this color
	NSUInteger					score;												///< Score reached in this level
	NSTimeInterval			time;													///< time used to clear this level
}

@property (assign, nonatomic) NSUInteger marblesInLevel;
@property (assign, nonatomic) NSUInteger removedMarbles;
@property (assign, nonatomic) NSUInteger score;
@property (assign, nonatomic) NSTimeInterval time;
@property (readonly, nonatomic) NSArray* clearedMarbleImages;
@property (readonly, nonatomic) NSDictionary *removedMarblesPerImage;

- (void) reset;
- (void) marbleCleared:(CMMarbleSprite*) marbleImage;  ///< called if a marble color was cleared from the level - does not effect any parameter other than clearedMarbleImages
- (void) marbleRemoved:(CMMarbleSprite*) removedImage; ///< call if a single marble was removed from the level - does not effect marblesInLevel!
@end
