//
//  MarbleSprite.m
//  CocosTest1
//
//  Created by Carsten Müller on 6/29/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//
#import "cocos2d.h"
#import "CMMarbleSprite.h"
#import "CMParticleSystemQuad.h"
#import "CMMarbleGameDelegate.h"
#import "CMMarblePowerProtocol.h"

@interface CMMarbleSprite ()
- (void) setGlossMapRect:(CGRect) glossRect;
- (ChipmunkBody*) circleBodyWithMass:(CGFloat)mass andRadius:(CGFloat) r;
- (ChipmunkShape *) circleShapeWithBody:(ChipmunkBody*) b andRadius:(CGFloat) r;
- (void) createOverlayTextureRect;
- (void) removeFromPhysics;
- (void) removeMarble;
@property (nonatomic, assign) CGPoint mapTextureCenter;
@property (nonatomic, retain) CMParticleSystemQuad *touchParticles;
@property (nonatomic, retain) CMParticleSystemQuad *powerUpParticles;
@end

@implementation CMMarbleSprite

@synthesize radius = radius_ ,marbleSetName = setName_,ballIndex=ballIndex_,
mapBottom=mapBottom_, mapLeft=mapLeft_,mapRight = mapRight_,mapTop=mapTop_,
shouldDestroy=shouldDestroy_,touchesNeighbour = touchesNeighbour_, lastSoundTime = lastSoundTime_;
@synthesize mapTextureCenter=mapTextureCenter_;

@synthesize touchParticles = particleSystem_, powerUpParticles=powerUpParticles_;
@synthesize gameDelegate = gameDelegate_;
@synthesize marbleAction = marbleAction_;

- (void) initializeDefaults
{
	self.soundName = DEFAULT_MARBLE_KLICK;
  self.touchParticles = nil;
	self.powerUpParticles = nil;
}

+ (CCSpriteFrame*) spriteFrameForBallSet:(NSString *)setName ballIndex:(NSInteger)ballIndex
{
	NSString* frameName = [NSString stringWithFormat:@"%@_%li",setName,(long)ballIndex];
	CCSpriteFrame* result = [[CCSpriteFrameCache sharedSpriteFrameCache]  spriteFrameByName:frameName];
	return result;
}

-(id) initWithBallSet:(id)sN ballIndex:(NSInteger)bI mass:(CGFloat)mass andRadius:(CGFloat)r
{
	if ((self=[super initWithSpriteFrame:[[self class]spriteFrameForBallSet:sN ballIndex:bI]])) {
		[self initializeDefaults];
    CCGLProgram *k =[[CCShaderCache sharedShaderCache] programForKey:kCMMarbleGlossMapShader];
		
    self.shaderProgram = k;
		
    self.radius = r;
    self.marbleSetName=sN;
    self.ballIndex = bI;
    self.chipmunkBody = [self circleBodyWithMass:mass andRadius:r];
		self.chipmunkBody.data = self;
		[self addShape:[self circleShapeWithBody:self.chipmunkBody andRadius:self.radius]];
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
		[self addShape:[self circleShapeWithBody:self.chipmunkBody andRadius:self.radius]];

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
  [self->setName_ release];
  self->setName_ = nil;
	self.soundName = nil;
	self.powerUpParticles = nil;
	self.touchParticles = nil;
  self.marbleAction.parentMarble=nil;
	self.marbleAction = nil;
	[super dealloc];
}

- (void) cleanup
{
  ChipmunkSpace *space = self.chipmunkBody.space;
  [space remove:self];
  [super cleanup];
}

-(void) onEnterTransitionDidFinish
{
  [self createOverlayTextureRect];
}


#pragma mark -
#pragma mark Properties

- (NSString*) frameName
{
  if (self.marbleSetName && self.ballIndex) {
    return [NSString stringWithFormat:@"%@_%li",self.marbleSetName,(long)self.ballIndex];
  }
  return nil;
}

- (NSString*) overlayName
{
  NSString *sn = self.marbleSetName;
	//  if ([sn isEqualToString:@"Billard"]) {
	//    sn=@"DDR";
	//  }
  if (sn) {
    return [NSString stringWithFormat:@"%@_Overlay",sn];
  }
  return nil;
}

-(void) setMarbleSetName:(NSString *)setN
{
  if (![self->setName_ isEqualToString:setN]) {
    [self->setName_ autorelease];
    self->setName_ = [setN retain];
    
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
  self->mapTextureCenter_=CGPointMake( tx , ty);
 
}

- (void) setShouldDestroy:(BOOL)sD
{
	self->shouldDestroy_ = sD;
	if (self->shouldDestroy_) {
		if (self.touchParticles) {
			[self.touchParticles removeFromParentAndCleanup:YES];
		}
		if (self.powerUpParticles) {
			[self.powerUpParticles removeFromParentAndCleanup:YES];
		}
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
	if ((self->ballIndex_ != bI) && (bI >0)) {
		self->ballIndex_ = bI;
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:self.frameName];
		[self setTextureRect:frame.rect rotated:frame.rotated untrimmedSize:frame.rect.size];
	}
}


- (void) triggerParticles
{
  if (self.touchParticles) {
    [self.gameDelegate removeEffect:self.touchParticles];
  }
  /// @todo: refactor the following line is stupid.

  CMParticleSystemQuad *parts = [self.gameDelegate particleSystemForName:MARBLE_TOUCH_EFFECT];

  self.touchParticles = parts;
  self.touchParticles.autoRemoveOnFinish = NO;
  self.touchParticles.anchorPoint = CGPointMake(0.5, 0.5);
  self.touchParticles.position = self.position;
  //  [self addChild:particleSystem_];
  [self.gameDelegate addEffect:self.touchParticles];



}
- (void) setTouchesNeighbour:(BOOL)tN
{
  if (self->touchesNeighbour_ != tN) {
    self->touchesNeighbour_ = tN;
		if (tN) {
			if(!self.touchParticles)
				[self triggerParticles];
		}else{
			if (self.touchParticles) {
				[self.gameDelegate removeEffect:self.touchParticles];
				self.touchParticles = nil;
			}
		}
	}
}

- (void) setMarbleAction:(NSObject<CMMarblePowerProtocol>*)marbleA
{
	if (marbleA != self->marbleAction_) {
		if (self->marbleAction_) {
			[self->marbleAction_.particleEffect removeFromParentAndCleanup:YES];
		}
		[self->marbleAction_ autorelease];
		self->marbleAction_ = [marbleA retain];
		if (marbleA) {
      marbleA.parentMarble = self;
			self.powerUpParticles = marbleA.particleEffect;
			[self.gameDelegate addMarbleEffect:self.powerUpParticles];
			self.powerUpParticles.position = self.position;
		}
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


  CGPoint tk = ccpRotateByAngle(coord,self->mapTextureCenter_,rad);

  
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
	if (self.touchParticles) {
		self.touchParticles.position = [super position];
	}
	if (self.powerUpParticles) {
		self.powerUpParticles.position = [super position];
	}
  if (self.marbleAction) {
    [self.marbleAction update];
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

  {
    CGPoint t =[super position];
    if (self.touchParticles) {
      self.touchParticles.position = t;
    }
//		if (self.powerUpParticles) {
//			self.powerUpParticles.position = t;
//		}
    if (self.marbleAction) {
      [self.marbleAction update];
    }
  }
}


#pragma mark -
#pragma mark Physics

- (ChipmunkShape *) circleShapeWithBody:(ChipmunkBody*) b andRadius:(CGFloat) r
{
	ChipmunkShape *shp = [ChipmunkCircleShape circleWithBody:b radius:r offset:cpv(0, 0)];
	shp.collisionType = COLLISION_TYPE_MARBLE;
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
	ChipmunkBody 	*body = self.chipmunkBody;
	ChipmunkSpace *space = body.space;
	[space smartRemove:self];
}

@end
