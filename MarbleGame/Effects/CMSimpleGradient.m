//
//  CMSimpleGradient.m
//  MarbleGame
//
//  Created by Carsten Müller on 9/26/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMSimpleGradient.h"

@interface CMSimpleGradient ()
@property (nonatomic,assign) ccColor4F diffColor;
@end

@implementation CMSimpleGradient
@synthesize startColor=startColor_,endColor=endColor_,diffColor = diffColor_;

- (id) init
{
  return [self initWithStartColor:ccc4f(0.0, 0.0, 0.0, 1.0)
                         endColor:ccc4f(1.0, 1.0, 1.0, 1.0)];
}
- (ccColor4F) diffColorForStart:(ccColor4F)start end:(ccColor4F)end
{
  ccColor4F dColor;
  dColor.r = (end.r - start.r);
  dColor.g = (end.g - start.g);
  dColor.b = (end.b - start.b);
  dColor.a = (end.a - start.a);
  return dColor;

}

- (id) initWithStartColor:(ccColor4F)sColor endColor:(ccColor4F)eColor
{
  self = [super init];
  if (self) {
    self.startColor = sColor;
    self.endColor = eColor;
    self.diffColor = [self diffColorForStart:self.startColor end:self.endColor];
  }
  return self;
}

- (void) setStartColor:(ccColor4F)sColor
{
  self->startColor_ = sColor;
  self.diffColor = [self diffColorForStart:self->startColor_ end:self.endColor];
}

- (void) setEndColor:(ccColor4F)endColor
{
  self->endColor_ = endColor;
  self.diffColor = [self diffColorForStart:self.startColor end:self->endColor_];
}

-(ccColor4F) colorForNormalizedPosition:(CGFloat)value
{
  ccColor4F dColor = self.diffColor;
  dColor.r *= value;
  dColor.g *= value;
  dColor.b *= value;
  dColor.a *= value;

  dColor.r += self.startColor.r;
  dColor.g += self.startColor.g;
  dColor.b += self.startColor.b;
  dColor.a += self.startColor.a;
  return dColor;

}
@end
