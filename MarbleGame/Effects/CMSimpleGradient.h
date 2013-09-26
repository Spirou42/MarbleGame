//
//  CMSimpleGradient.h
//  MarbleGame
//
//  Created by Carsten Müller on 9/26/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CMSimpleGradient : NSObject
@property (nonatomic,assign) ccColor4F startColor;
@property (nonatomic,assign) ccColor4F endColor;

- (id) initWithStartColor:(ccColor4F)sColor endColor:(ccColor4F)eColor;
-(ccColor4F) colorForNormalizedPosition:(CGFloat) value;
@end
