//
//  CMLevelSelectItem.h
//  MarbleGame
//
//  Created by Carsten Müller on 10/7/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCLayer.h"

@class CCSprite;
@interface CMLevelSelectItem : CCLayer

@property (nonatomic,retain) CCSprite *icon;

@property (nonatomic,retain) NSString *name;

@end
