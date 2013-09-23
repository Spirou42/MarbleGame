//
//  CMSoundSprite.h
//  MarbleGame
//
//  Created by Carsten Müller on 9/23/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCSprite.h"
#import "CMObjectSoundProtocol.h"
#import "CMMarbleGameDelegate.h"

@interface CMSoundSprite : CCSprite <CMObjectSoundProtocol>
@property (nonatomic, assign) id<CMMarbleGameDelegate> gameDelegate;
@end
