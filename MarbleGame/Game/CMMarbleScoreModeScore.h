//
//  CMMarbleScoreModeScore.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/14/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMMarbleGameScoreModeProtocol.h"

@protocol CMMarbleGameDelegate;

@interface CMMarbleScoreModeScore : NSObject <CMMarbleGameScoreModeProtocol>

@property (nonatomic,assign) NSObject<CMMarbleGameDelegate>* gameDelegate;
@property (nonatomic,assign) NSInteger comboHits;
@end
