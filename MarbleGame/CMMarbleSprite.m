//
//  MarbleSprite.m
//  CocosTest1
//
//  Created by Carsten Müller on 6/29/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//
#import "cocos2d.h"
#import "CMMarbleSprite.h"
#import "CMMarbleOverlaySprite.h"

#define MARBLE_FRICTION   .9
#define MARBLE_ELASTICITY .2

@implementation CMMarbleSprite
@synthesize shape,radius,setName,ballIndex;

- (NSString*) frameName
{
  if (self.setName) {
    return [NSString stringWithFormat:@"%@_%li",self.setName,self.ballIndex];
  }
  return nil;
}

- (NSString*) overlayName
{
  NSString *sn = self.setName;
  if ([sn isEqualToString:@"Billard"]) {
    sn=@"DDR";
  }
  if (sn) {
    return [NSString stringWithFormat:@"%@_Overlay",sn];
  }
  return nil;
}

- (ChipmunkShape *) circleShapeWithBody:(ChipmunkBody*) b andRadius:(CGFloat) r
{
	ChipmunkShape *shp = [ChipmunkCircleShape circleWithBody:b radius:r offset:cpv(0, 0)];
	shp.collisionType = [self class];
	shp.data = self;
	shp.friction=MARBLE_FRICTION;
	shp.elasticity=MARBLE_ELASTICITY;
	return shp;
}

- (ChipmunkBody*) circleBodyWithMass:(CGFloat)mass andRadius:(CGFloat) r
{
	cpFloat moment = cpMomentForCircle(mass, 0, r, cpv(0, 0));
	return [ChipmunkBody bodyWithMass:mass andMoment:moment];
}

- (void) createOverlayChild
{
	CCSprite *overlay = [CMMarbleOverlaySprite spriteWithSpriteFrameName:self.overlayName];
	overlay.scale = 1.05;
	overlay.position = ccp(self.contentSize.width/2.0-.5, self.contentSize.height/2.0);
//	overlay.blendFunc = (ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_COLOR};//{GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};
	//overlay.blendFunc = (ccBlendFunc) {GL_ZERO, GL_ONE_MINUS_SRC_ALPHA};
	[self addChild:overlay];
}

-(id) initWithBallSet:(id)sN ballIndex:(NSInteger)bI mass:(CGFloat)mass andRadius:(CGFloat)r
{
  NSString* frameName = [NSString stringWithFormat:@"%@_%li",sN,bI];
  if ((self=[super initWithSpriteFrameName:frameName])) {
    self.radius = r;
    self.ballIndex = bI;
    self.setName=sN;
    self.chipmunkBody = [self circleBodyWithMass:mass andRadius:r];
		self.shape = [self circleShapeWithBody:self.chipmunkBody andRadius:self.radius];
		CGPoint scale = ccp(1,1);
		CGFloat t = r*2.0;
		scale.x = t/self.contentSize.width;
		scale.y = t/self.contentSize.height;
		self.scaleX = scale.x;
		self.scaleY = scale.y;
  }
  return self;
}

- (id) initWithSpriteFrameName:(NSString*)fn mass:(CGFloat)mass andRadius:(CGFloat)r
{
	if( (self = [super initWithSpriteFrameName:fn]) ){
		self.radius =r;
		self.chipmunkBody =[self circleBodyWithMass:mass andRadius:self.radius];
		self.shape = [self circleShapeWithBody:self.chipmunkBody andRadius:self.radius];

		CGPoint scale = ccp(1,1);
		CGFloat t = r*2.0;
		scale.x = t/self.contentSize.width;
		scale.y = t/self.contentSize.height;
		self.scaleX = scale.x;
		self.scaleY = scale.y;
	}
	return self;
}


-(void) setSetName:(NSString *)setN
{
  if (![self->setName isEqualToString:setN]) {
    [self->setName autorelease];
    self->setName = [setN retain];
    
    if (self.frameName) {
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:self.frameName];
      CGRect textureRect=frame.rect;
      self.textureRect= textureRect;
      [self removeAllChildren];
      [self createOverlayChild];
    }else{
      self.textureRect=CGRectMake(0, 0, 0, 0);
    }
  }
}

- (void) updateTransform
{
	for (CCSprite *child in self.children) {
    child.dirty = YES;
		child.rotation = -self.rotation;
	}
	[super updateTransform];
}

- (void) cleanup
{
  ChipmunkSpace *space = self.shape.body.space;
  [space remove:self];
  [super cleanup];
}

- (void) dealloc
{
//	[self removeAllChildren];
	self.shape = nil;
	self.setName = nil;
  
	[super dealloc];
}

#pragma mark - 
#pragma mark ChipmunkObject
- (id <NSFastEnumeration>) chipmunkObjects
{
	return [NSArray arrayWithObjects:self.chipmunkBody, self.shape, nil];
}

#pragma mark - 
#pragma mark NSCopying

- (id) copyWithZone:(NSZone *)zone
{
	id result = [[[self class]alloc]initWithSpriteFrameName:self.frameName mass:self.chipmunkBody.mass andRadius:self.radius];
	return result;
}
@end
