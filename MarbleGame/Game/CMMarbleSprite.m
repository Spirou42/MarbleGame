//
//  MarbleSprite.m
//  CocosTest1
//
//  Created by Carsten Müller on 6/29/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//
#import "cocos2d.h"
#import "CMMarbleSprite.h"



@interface CMMarbleSprite ()
- (void) setGlossMapRect:(CGRect) glossRect;
- (ChipmunkBody*) circleBodyWithMass:(CGFloat)mass andRadius:(CGFloat) r;
- (ChipmunkShape *) circleShapeWithBody:(ChipmunkBody*) b andRadius:(CGFloat) r;
- (void) createOverlayTextureRect;
- (void) removeFromPhysics;
- (void) removeMarble;
@end

@implementation CMMarbleSprite

@synthesize shape,radius,setName,ballIndex, mapBottom, mapLeft,mapRight,mapTop,shouldDestroy,touchesNeighbour;

+ (CCSpriteFrame*) spriteFrameForBallSet:(NSString *)setName ballIndex:(NSInteger)ballIndex
{
	NSString* frameName = [NSString stringWithFormat:@"%@_%li",setName,(long)ballIndex];
	CCSpriteFrame* result = [[CCSpriteFrameCache sharedSpriteFrameCache]  spriteFrameByName:frameName];
	return result;
}

-(id) initWithBallSet:(id)sN ballIndex:(NSInteger)bI mass:(CGFloat)mass andRadius:(CGFloat)r
{
    if ((self=[super initWithSpriteFrame:[[self class]spriteFrameForBallSet:sN ballIndex:bI]])) {
    
    CCGLProgram *k =[[CCShaderCache sharedShaderCache] programForKey:kCMMarbleGlossMapShader];

    self.shaderProgram = k;

    self.radius = r;
    self.setName=sN;
    self.ballIndex = bI;
    self.chipmunkBody = [self circleBodyWithMass:mass andRadius:r];
		self.chipmunkBody.data = self;
		self.shape = [self circleShapeWithBody:self.chipmunkBody andRadius:self.radius];
		CGPoint scale = ccp(1,1);
		CGFloat t = r*2.0;
		scale.x = t/self.contentSize.width;
		scale.y = t/self.contentSize.height;
		self.scaleX = 0.01;
		self.scaleY = 0.01;
		[self runAction:[CCScaleTo actionWithDuration:MARBLE_CREATE_TIME scaleX:scale.x scaleY:scale.y]];
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

- (void) dealloc
{
	//	[self removeAllChildren];
	self.shape.body = nil;
	self.shape = nil;
  [self->setName release];
  self->setName = nil;
	[super dealloc];
}

- (void) cleanup
{
  ChipmunkSpace *space = self.shape.body.space;
  [space remove:self];
  [super cleanup];
}


#pragma mark -
#pragma mark Properties

- (NSString*) frameName
{
  if (self.setName && self.ballIndex) {
    return [NSString stringWithFormat:@"%@_%li",self.setName,(long)self.ballIndex];
  }
  return nil;
}

- (NSString*) overlayName
{
  NSString *sn = self.setName;
	//  if ([sn isEqualToString:@"Billard"]) {
	//    sn=@"DDR";
	//  }
  if (sn) {
    return [NSString stringWithFormat:@"%@_Overlay",sn];
  }
  return nil;
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
      [self createOverlayTextureRect];
    }else{
      self.textureRect=CGRectMake(0, 0, 0, 0);
    }
  }
}

- (void) setGlossMapRect:(CGRect) glossRect
{
  CCTexture2D *tex	= (_batchNode) ? [_textureAtlas texture] : _texture;
	if(!tex)
		return;
  
	float atlasWidth = (float)tex.pixelsWide;
	float atlasHeight = (float)tex.pixelsHigh;

  
  self.mapLeft    = glossRect.origin.x;
  self.mapRight   = (glossRect.origin.x + glossRect.size.width);
  self.mapTop     = glossRect.origin.y;
  self.mapBottom	= (glossRect.origin.y + glossRect.size.height);

  _quad.bl.mapCoords.u = self.mapLeft 	/ atlasWidth;
  _quad.bl.mapCoords.v = self.mapBottom / atlasHeight;
  _quad.br.mapCoords.u = self.mapRight 	/ atlasWidth;
  _quad.br.mapCoords.v = self.mapBottom / atlasHeight;
  _quad.tl.mapCoords.u = self.mapLeft		/ atlasWidth;;
  _quad.tl.mapCoords.v = self.mapTop		/ atlasHeight;
  _quad.tr.mapCoords.u = self.mapRight 	/ atlasWidth;
  _quad.tr.mapCoords.v = self.mapTop		/ atlasHeight;

  CGFloat tx = self.mapLeft + ((self.mapRight-self.mapLeft)/2.0);
  CGFloat ty = self.mapBottom + ((self.mapTop-self.mapBottom)/2.0);
  self->mapTextureCenter=CGPointMake( tx , ty);
 
}

- (void) setShouldDestroy:(BOOL)sD
{
	self->shouldDestroy = sD;
	if (self->shouldDestroy) {
		// create an scale action and trigger the calling of selfDestruct.
		[self removeFromPhysics];
		id actionScale = [CCScaleTo actionWithDuration:MARBLE_DESTROY_TIME scale:.01f];
		id actionCallBack = [CCCallFunc actionWithTarget:self selector:@selector(removeMarble)];
		id actionSequence = [CCSequence actions:actionScale, actionCallBack, nil];
		[self runAction:actionSequence];
	}
}

- (void) setBallIndex:(NSInteger)bI
{
	if (self->ballIndex != bI) {
		self->ballIndex = bI;
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:self.frameName];
		[self setTextureRect:frame.rect rotated:frame.rotated untrimmedSize:frame.rect.size];
	}

}


#pragma mark -
#pragma mark Rendering

- (void) removeMarble
{
	[self removeFromParent];
}

- (void) createOverlayTextureRect
{
  CCSpriteFrame *overlayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:self.overlayName];
  [self setGlossMapRect:overlayFrame.rect];
}


- (ccTex2F) rotateCoord:(CGPoint) coord
{
	CCTexture2D *tex	= (_batchNode) ? [_textureAtlas texture] : _texture;
	float atlasWidth = (float)tex.pixelsWide;
	float atlasHeight = (float)tex.pixelsHigh;


  float rad = CC_DEGREES_TO_RADIANS(self.rotation);


  CGPoint tk = ccpRotateByAngle(coord,self->mapTextureCenter,rad);

  
// tk   = ccpRotate(k,rPoint);
  ccTex2F result;
  result.u=tk.x/atlasWidth;
  result.v=tk.y/atlasHeight;
  return result;
}


- (void) rotateMapCoords
{
  CGPoint bl = CGPointMake(self.mapLeft, self.mapBottom);
  CGPoint tl = CGPointMake(self.mapLeft,self.mapTop);
  CGPoint br = CGPointMake(self.mapRight,self.mapBottom);
  CGPoint tr = CGPointMake(self.mapRight,self.mapTop);
  _quad.bl.mapCoords = [self rotateCoord:bl];
  _quad.br.mapCoords = [self rotateCoord:br];
  _quad.tl.mapCoords = [self rotateCoord:tl];
  _quad.tr.mapCoords = [self rotateCoord:tr];
}

- (void) draw
{
  [self rotateMapCoords];
  [super draw];
	if (self.touchesNeighbour) {
		ccDrawColor4F(0.2, 0.9, 0.1, 0.5);
		glLineWidth(1.8);
		CGFloat r = self.contentSize.width / 2.0;
		ccDrawCircle(ccp(r,r), r, 0, 36, NO);

	}
}

- (void) updateTransform
{
//	for (CCSprite *child in self.children) {
//    child.dirty = YES;
//		child.rotation = -self.rotation;
//	}

	[super updateTransform];
  [self rotateMapCoords];  
}


#pragma mark -
#pragma mark Physics

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

- (void) removeFromPhysics
{
	ChipmunkBody 	*body = self.shape.body;
	ChipmunkSpace *space = body.space;
	[space remove:self];
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
	return [self retain];
//	id result = [[[self class]alloc]initWithSpriteFrameName:self.frameName mass:self.chipmunkBody.mass andRadius:self.radius];
//	return result;
}
@end
