//
//  MarbleGameAppDelegate+GameDelegate.m
//  MarbleGame
//
//  Created by Carsten Müller on 7/30/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MarbleGameAppDelegate+GameDelegate.h"
//#import "CMMarblePlayerOld.h"
#import "CMMarblePlayer.h"
#import "CMMPSettings.h"
#import "CMMPLevelSet.h"
#import "CMMPLevelStat.h"
#import "CMMarbleLevel.h"
#import "CMMPSettings.h"
#import "CMMarbleLevelSet.h"
#import "CMMarbleGameScoreModeProtocol.h"
#import "CMMarbleScoreModeScore.h"
#import "AppDelegate.h"
#import "SimpleAudioEngine.h"

// to be implemented
//#import "CMMarbleScoreModeTime.h"
//#import "CMMarbleScoreModeRelaxed.h"
NSMutableDictionary *_scoreModeDelegates;

@implementation MarbleGameAppDelegate (GameDelegate)

//@dynamic levelSet,marbleSets;

-(void) registerUserDefaults
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud registerDefaults:@{@"MarbleSet":@"DDR",
												 @"currentPlayer":NSUserName(),
												 }];
}

- (NSObject<CMMarbleGameScoreModeProtocol>*) currentScoreDelegate
{
	CMMarblePlayer *player = [self currentPlayer];
	NSString *scoreModeName = player.settings.scoreMode;
	return (NSObject <CMMarbleGameScoreModeProtocol>*)[_scoreModeDelegates objectForKey:scoreModeName];
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

- (void) initializeScoreModes
{
	_scoreModeDelegates = [[NSMutableDictionary dictionary]retain];
	[_scoreModeDelegates setObject:[[CMMarbleScoreModeScore new]autorelease] forKey:@"score"];
}

- (void) initializeMarbleGame
{
  // load shaders
  GLchar * fragSource = (GLchar*) [[NSString stringWithContentsOfFile:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"GlossMapShader.fsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
  GLchar * vertSource = (GLchar*) [[NSString stringWithContentsOfFile:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"GlossMapShader.vsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
  CCGLProgram *shaderProgram = [[[CCGLProgram alloc] initWithVertexShaderByteArray:vertSource fragmentShaderByteArray:fragSource] autorelease];
  
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

	
//	[CCSpriteFrame frameWithTextureFilename:DEFAULT_COMBO_EFFECT_FILE rect:ccp(0, 0)];
//  [[CCSpriteFrameCache sharedSpriteFrameCache] add]
	// reading ball set names
	[self getBallSetNamesFromFile:@"Balls.plist"];
	
  
  // loading default LevelSet
  NSURL * bla = [NSBundle URLForResource:DEFAULT_LEVELSET_NAME withExtension:DEFAULT_LEVELSET_EXTENSION subdirectory:@"." inBundleWithURL:[[NSBundle mainBundle]bundleURL]];
	// register LevelSet directory in searchPath
	NSArray *oldSearchPath = [[CCFileUtils sharedFileUtils] searchPath];
	NSMutableArray *newSearchPath = [oldSearchPath mutableCopy];
	[newSearchPath addObject:[bla path]];
	[[CCFileUtils sharedFileUtils] setSearchPath:newSearchPath];
	
  self.levelSet = [CMMarbleLevelSet levelSetWithURL:bla];

	[newSearchPath release];
	
  
	// initialize known score Modes
	[self initializeScoreModes];
	
	// preload music and effects
	[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:DEFAULT_BACKGROUND_MUSIC];
	[[SimpleAudioEngine sharedEngine] preloadEffect:DEFAULT_MARBLE_KLICK];
}

#pragma mark - 
#pragma mark Core Data

- (NSURL*) defaultStoreURL
{
	NSURL *result = nil;
#if __CC_PLATFORM_MAC
	result = [[self applicationStoreDirectory] URLByAppendingPathComponent:@"CMMarbleGameStatistics.storedata"];
#else
	result = [[NSBundle mainBundle] URLForResource:@"CMMarbleGameStatistics" withExtension:@"momd"];
#endif
	return result;
}
- (id) defaultStore
{
	return [[self persistentStoreCoordinator] persistentStoreForURL:[self defaultStoreURL]];
}


- (CMMPSettings*) createDefaultSettings
{
	CMMPSettings* settings = [NSEntityDescription insertNewObjectForEntityForName:@"CMMPSettings" inManagedObjectContext:[self managedObjectContext]];
	settings.marbleTheme = DEFAULT_MARBLE_THEME;

	[self.managedObjectContext assignObject:settings toPersistentStore:[self defaultStore]];
	return settings;
}

- (CMMPLevelSet*) createLevelSetWithName:(NSString*) levelSetName
{
	CMMPLevelSet *newLevelSet = [NSEntityDescription insertNewObjectForEntityForName:@"CMMPLevelSet" inManagedObjectContext:[self managedObjectContext]];
	newLevelSet.name = levelSetName;
	
	[[self managedObjectContext] assignObject:newLevelSet toPersistentStore:[self defaultStore]];
	
	NSError* error;
	[[self managedObjectContext] save:&error];
	return newLevelSet;
}

- (CMMarblePlayer*) fetchPlayerWithName:(NSString*) playerName
{
	NSEntityDescription *entityDescription = [NSEntityDescription
																						entityForName:@"CMMarblePlayer" inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	// Set example predicate and sort orderings...
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name == %@",playerName];
	
	[request setPredicate:predicate];
	
	NSError *error;
	NSArray *array = [[self managedObjectContext] executeFetchRequest:request error:&error];
	[request release];
	if (array.count > 0) {
		return [array objectAtIndex:0];
	}
	return nil;
}

- (CMMPLevelSet*) fetchLevelSetWithName:(NSString*)levelSetName forPlayer:(CMMarblePlayer*) player
{
	NSEntityDescription  *levelSetDescription = [NSEntityDescription entityForName:@"CMMPLevelSet" inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CMMPLevelSet"];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(player == %@) && (name == %@)",player,levelSetName];
	[request setPredicate:predicate];
	
	NSError *error;
	NSArray *result= [self.managedObjectContext executeFetchRequest:request error:&error];
	if (result.count) {
		return [result objectAtIndex:0];
	}
	return nil;
}

- (CMMPLevelStat*) fetchLevelStatWithName:(NSString*) levelName forPlayer:(CMMarblePlayer*) player
{
	CMMPLevelSet * currentLevelSet = [self fetchLevelSetWithName:player.currentLevelSet forPlayer:player];
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CMMPLevelStat"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
														@"(levelset == %@) AND (scoreMode == %@) AND (name == %@)",
														currentLevelSet,player.settings.scoreMode,levelName];
	request.predicate = predicate;
	
	NSError *error;
	NSArray* array = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (array.count) {
		return [array objectAtIndex:0];
	}
	return nil;
}

- (CMMarblePlayer*) createPlayerWithName:(NSString*) playerName
{
	CMMarblePlayer* newPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"CMMarblePlayer" inManagedObjectContext:[self managedObjectContext]];

	newPlayer.name = playerName;
	newPlayer.currentLevelSet = DEFAULT_LEVELSET_NAME;
	

	[[self managedObjectContext] assignObject:newPlayer toPersistentStore:[self defaultStore]];
	CMMPLevelSet *defaultSet = [self createLevelSetWithName:DEFAULT_LEVELSET_NAME];
	[newPlayer addLevelSetsObject:defaultSet];
	
	CMMPSettings *defaultSettings = [self createDefaultSettings];
	newPlayer.settings = defaultSettings;
	NSError* error;
	[[self managedObjectContext] save:&error];

	return newPlayer;
}

- (CMMarblePlayer*) currentPlayer
{
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	NSString* currentPlayerName = [ud stringForKey:@"currentPlayer"];
	CMMarblePlayer * currentPlayer = [self fetchPlayerWithName:currentPlayerName];
	if (!currentPlayer) {
		currentPlayer = 	[self createPlayerWithName:currentPlayerName];
	}
	return currentPlayer;
}


- (CMMPLevelStat*) temporaryStatisticFor:(CMMarblePlayer *)player andLevel:(CMMarbleLevel *)level
{
	CMMPLevelStat* result = [NSEntityDescription insertNewObjectForEntityForName:@"CMMPLevelStat" inManagedObjectContext:[self managedObjectContext]];
	result.name = level.name;
	if (player.currentLevelStat && (player.currentLevelStat.levelset == nil)){
		[self.managedObjectContext deleteObject:player.currentLevelStat] ;
	}
	player.currentLevelStat = result;
	result.scoreMode = player.settings.scoreMode;
	[[self managedObjectContext] assignObject:result toPersistentStore:[self defaultStore]];
	NSError *error;
	[[self managedObjectContext] save:&error];
	
	return result;
}

- (CMMPLevelStat*) statisticsForPlayer:(CMMarblePlayer *)player andLevel:(CMMarbleLevel *)level
{
	CMMPLevelStat * result = [self fetchLevelStatWithName:level.name forPlayer:player];
	
	return result;
}

- (void) addStatistics:(CMMPLevelStat *)stat toPlayer:(CMMarblePlayer *)player
{
	CMMPLevelStat * currentStat = [self fetchLevelStatWithName:stat.name forPlayer:player];
	CMMPLevelSet * currentSet = [self fetchLevelSetWithName:player.currentLevelSet forPlayer:player];
	if (currentStat) {
		[currentSet removeLevelsObject:currentStat];
		[self.managedObjectContext deleteObject:currentStat];
	}
	stat.player = nil;
	[currentSet addLevelsObject:stat];
	
}

- (BOOL) player:(CMMarblePlayer *)player hasPlayedLevel:(NSString *)name
{
	CMMPLevelStat *stat = [self fetchLevelStatWithName:name forPlayer:player];
	return  stat != nil;
}

@end
