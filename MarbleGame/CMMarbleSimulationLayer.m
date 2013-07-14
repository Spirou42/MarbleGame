//
//  HelloWorldLayer.m
//  CocosTest1
//
//  Created by Carsten Müller on 6/28/13.
//  Copyright Carsten Müller 2013. All rights reserved.
//

#import "AppDelegate.h"

// Import the interfaces
#import "CMMarbleSimulationLayer.h"
#import "CMMarbleSprite.h"
#import "CMMarbleMainMenuScene.h"
#import "SceneHelper.h"
enum {
	kTagParentNode = 1,
};
@interface CCMenu (MyLayout)
- (void) adjustContentSize;
@end

static NSString *borderType = @"borderType";
#pragma mark - HelloWorldLayer

@interface CMMarbleSimulationLayer ()
-(void) addNewSpriteAtPosition:(CGPoint)pos;
-(void) initPhysics;
@end


@implementation CMMarbleSimulationLayer

@synthesize space = _space, batchNode=_bathNode, currentMarbleSet=_currentMarbleSet, debugLayer=_debugLayer, simulationRunning=_simulationRunning;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CMMarbleSimulationLayer *layer = [CMMarbleSimulationLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
  // WithColor:ccc4(255, 128, 0, 255)
	if( (self=[super init])) {
    
		// enable events
#ifdef __CC_PLATFORM_IOS
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.mouseEnabled = YES;
#endif
		


		
		
		// init physics
		[self initPhysics];
		

		// Use batch node. Faster

#if 0
		self.batchNode= [CCSpriteBatchNode batchNodeWithFile:@"Balls.png" capacity:100];
#else
    self.batchNode = [CCNode node];
#endif
		[self addChild:self.batchNode z:0 tag:kTagParentNode];
		
		[self addNewSpriteAtPosition:ccp(200,200)];

		// this starts the update automatically
    self.simulationRunning = YES;
	}
	
	return self;
}

-(void) initPhysics
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	self.space = [[[ChipmunkSpace alloc] init] autorelease];
	
	self.space.gravity = cpv(0.0, -SPACE_GRAVITY);
	CGRect p = CGRectZero;
	p.size = s;
	CGRect newBounds = CGRectInset(p,0,0);
	[self.space addBounds:newBounds
							thickness:20.0
						 elasticity:BORDER_ELASTICITY
							 friction:BORDER_FRICTION
								 layers:CP_ALL_LAYERS
									group:CP_NO_GROUP
					collisionType:borderType];
	
	
	_debugLayer = [CCPhysicsDebugNode debugNodeForCPSpace:self.space.space];
	_debugLayer.visible = NO;
	[self addChild:_debugLayer z:100];
}

- (void)dealloc
{
  
	self.space = nil;
  
	
	[super dealloc];
	
}

-(void) update:(ccTime) delta
{
	// Should use a fixed size step based on the animation interval.
	int steps = 2;
	CGFloat dt = [[CCDirector sharedDirector] animationInterval]/(CGFloat)steps;
	
	for(int i=0; i<steps; i++){
		[self.space step:dt];
    //		cpSpaceStep(_space, dt);
	}
}
#pragma mark -
#pragma mark Properties

- (void) setSimulationRunning:(BOOL)run
{
  if (self->_simulationRunning != run) {
    CCScheduler *s =self.scheduler;
    self->_simulationRunning = run;
    if (run) {
      [self scheduleUpdate];
    }else{
      [s unscheduleUpdateForTarget:self];
    }
  }
}


#pragma mark -
#pragma mark actions


-(void) addNewSpriteAtPosition:(CGPoint)pos
{
	// physics body
  static int marbleIndex = 1;
  NSString *marbleSet =[[NSUserDefaults standardUserDefaults]stringForKey:@"MarbleSet"];
	NSLog(@"MarbleSet: %@",marbleSet);
  
	CMMarbleSprite *ms = [[[CMMarbleSprite alloc]initWithBallSet:marbleSet ballIndex:marbleIndex mass:MARBLE_MASS andRadius:MARBLE_RADIUS]autorelease];
	marbleIndex= ((marbleIndex+1)%9);
  if (!marbleIndex) {
    marbleIndex=1;
  }
	[self.space add:ms];
	ms.position = pos;
	[self.batchNode addChild:ms];
	[ms createOverlayTextureRect];
  
}

-(BOOL) ccMouseDown:(NSEvent *)event
{
	CGPoint location = [(CCDirectorMac*)[CCDirector sharedDirector] convertEventToGL:event];
	[self addNewSpriteAtPosition:location];
	
	return YES;
}

#pragma mark -
#pragma mark Simulation

- (void) startSimulation
{
  self.simulationRunning = YES;
}

- (void) stopSimulation
{
  self.simulationRunning = NO;
}

- (void) resetSimulation
{
  self.simulationRunning=NO;
  [self.batchNode removeAllChildren];
  self.simulationRunning = YES;
}
- (void) retextureMarbles
{
  NSString *marbleSet =[[NSUserDefaults standardUserDefaults]stringForKey:@"MarbleSet"];
  for (CMMarbleSprite *marble in self.batchNode.children) {
    marble.setName=marbleSet;
  }
}


@end

@implementation CCMenu (MyLayout)

-(void) adjustContentSize
{
	CGRect contentRect = CGRectZero;
	for (CCNode *childNode in self.children) {
    
    CGRect childRect = childNode.boundingBox;
		contentRect = CGRectUnion(contentRect, childRect);
	}
	CGPoint offset = contentRect.origin;
	for (CCNode *childNode in self.children) {
    CGPoint pos = childNode.position;
		pos.x -=offset.x;
		pos.y -=offset.y;
    //		childNode.position = pos;
	}
	self.contentSize = contentRect.size;
	[self alignItemsHorizontallyWithPadding:10.0];
}


@end
