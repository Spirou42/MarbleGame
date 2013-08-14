//
//  CMMarbleBatchNode.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/14/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarbleBatchNode.h"
#import "cocos2d.h"

@implementation CMMarbleBatchNode
-(id)initWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity
{
	if( (self=[super initWithTexture:tex capacity:capacity]) ) {
    CCGLProgram *k =[[CCShaderCache sharedShaderCache] programForKey:kCMMarbleGlossMapShader];
    self.shaderProgram = k;
  }
  return self;
}
@end
