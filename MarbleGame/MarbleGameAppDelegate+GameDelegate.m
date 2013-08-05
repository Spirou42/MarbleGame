//
//  MarbleGameAppDelegate+GameDelegate.m
//  MarbleGame
//
//  Created by Carsten Müller on 7/30/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "MarbleGameAppDelegate+GameDelegate.h"
#import "CMMarblePlayer.h"
#import "CMMarbleLevelSet.h"
@implementation MarbleGameAppDelegate (GameDelegate)

//@dynamic levelSet,marbleSets;

-(void) registerUserDefaults
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

	CMMarblePlayer *defaultUser = [CMMarblePlayer playerWithName:NSUserName()];

	NSData *defaultPlayerData = [NSKeyedArchiver archivedDataWithRootObject:defaultUser];

  [ud registerDefaults:@{@"MarbleSet":@"DDR",
												 @"Players"  :@{NSUserName():defaultPlayerData},
												 @"currentPlayer":NSUserName()
												 }];
}

- (void) getBallSetNamesFromFile:(NSString*)filename
{
	NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:filename];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSArray* allKeys = [(NSDictionary*)[dict objectForKey:@"frames"] allKeys];
	NSMutableSet *setNames = [NSMutableSet setWithCapacity:20];
	for (NSString* name in allKeys) {
    NSString *prefix = [[name componentsSeparatedByString:@"_"]objectAtIndex:0];
		[setNames addObject:prefix];
	}
	
	self.marbleSets = [[setNames allObjects] sortedArrayUsingSelector:@selector(compare:)];
}

- (void) initializeMarbleGame
{
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
	
  [self registerUserDefaults];
  
	
  // adding sprite frames
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:DEFAULT_UI_PLIST];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Balls.plist"];
  
	// reading ball set names
	[self getBallSetNamesFromFile:@"Balls.plist"];
	
  // setting defaults for the Menu
	[CCMenuItemFont setFontName:DEFAULT_MENU_FONT];
	[CCMenuItemFont setFontSize:DEFAULT_MENU_FONT_SIZE];
  
  // loading default LevelSet
  NSURL * bla = [NSBundle URLForResource:DEFAULT_LEVELSET_NAME withExtension:DEFAULT_LEVELSET_EXTENSION subdirectory:@"." inBundleWithURL:[[NSBundle mainBundle]bundleURL]];
  
  self.levelSet = [CMMarbleLevelSet levelSetWithURL:bla];
  
  NSLog(@"Readl end");
}

- (CMMarblePlayer*) currentPlayer
{
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	NSString* currentPlayerName = [ud stringForKey:@"currentPlayer"];
	NSData *playerData = [[ud dictionaryForKey:@"Players"]objectForKey:currentPlayerName];
	CMMarblePlayer *currentPlayer= [NSKeyedUnarchiver unarchiveObjectWithData:playerData];
	return currentPlayer;
}
@end
