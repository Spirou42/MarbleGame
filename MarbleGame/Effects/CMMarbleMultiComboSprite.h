//
//  CMMarbleMultiComboSprite.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/7/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "cocos2d.h"
#import "CMObjectSoundProtocol.h"
#import "CMMarbleGameDelegate.h"

@interface CMMarbleMultiComboSprite : CCSprite <CMObjectSoundProtocol>

@property (nonatomic, assign) id<CMMarbleGameDelegate> gameDelegate;
@property (nonatomic, assign) CGPoint offset;
@end
