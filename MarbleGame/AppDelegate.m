//
//  AppDelegate.m
//  CocosTest1
//
//  Created by Carsten Müller on 6/28/13.
//  Copyright Carsten Müller 2013. All rights reserved.
//

#import "AppDelegate.h"
#import "CMMarbleSimulationLayer.h"
#import "CMMarbleMainMenuScene.h"
NSArray *marbleSets = nil;

@implementation CocosTest1AppDelegate
@synthesize window=window_, glView=glView_;

+(void) initialize
{
	marbleSets = @[@"Billard",@"Chat",@"Stars",@"DDR"];

}

- (NSArray*) marbleSets
{
	return marbleSets;
}

-(void) registerUserDefaults
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  [ud registerDefaults:@{@"MarbleSet":@"DDR"}];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	// enable FPS and SPF
	[director setDisplayStats:YES];
	
	// connect the OpenGL view with the director
	[director setView:glView_];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_AutoScale];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// Center main window
	[window_ center];
  
  // load shaders
  GLchar * fragSource = (GLchar*) [[NSString stringWithContentsOfFile:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"GlossMapShader.fsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
  GLchar * vertSource = (GLchar*) [[NSString stringWithContentsOfFile:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"GlossMapShader.vsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
  CCGLProgram *shaderProgram = [[CCGLProgram alloc] initWithVertexShaderByteArray:vertSource fragmentShaderByteArray:fragSource];
  
  [shaderProgram addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[shaderProgram addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	[shaderProgram addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
  [shaderProgram addAttribute:kCCAttributeNameMapCoord index:kCCVertexAttrib_MapCoords];
  
	[shaderProgram link];
	[shaderProgram updateUniforms];

  
  [[CCShaderCache sharedShaderCache]addProgram:shaderProgram forKey:kCMMarbleGlossMapShader];
	
	//CCScene *scene = [CCScene node];
//	[scene addChild:[MarbleLayer node]];
  [self registerUserDefaults];
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:DEFAULT_UI_PLIST];
	
	[CCMenuItemFont setFontName:DEFAULT_MENU_FONT];
	[CCMenuItemFont setFontSize:DEFAULT_MENU_FONT_SIZE];
	[director runWithScene:[CMMarbleMainMenuScene node]];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (void)dealloc
{
	[[CCDirector sharedDirector] end];
	[window_ release];
	[super dealloc];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
