//
//  CMMarbleLevelSet.m
//  Chipmonkey
//
//  Created by Carsten Müller on 6/20/12.
//  Copyright (c) 2012 Carsten Müller. All rights reserved.
//

#import "CMMarbleLevelSet.h"
#import "CMMarbleLevel.h"

@interface CMMarbleLevelSet ()

@end

@implementation CMMarbleLevelSet
@synthesize  baseURL,levelList;

+ (id) levelSetWithURL:(NSURL *)levelSetURL
{
  CMMarbleLevelSet* levelSet = [[[[self class]alloc]initWithURL:levelSetURL]autorelease];
  return levelSet;
}

- (NSArray*) loadLevelsFromDictionary:(NSDictionary*) dict
{
  NSMutableArray * mylevelList = [NSMutableArray array];
  NSDictionary* levels = [dict objectForKey:@"Levels"];
  NSArray *lList = [dict objectForKey:@"LevelOrder"];
  for (NSString *levelId in lList) {
    NSDictionary* levelDict= [levels objectForKey:levelId];
    if (levelDict) {
      CMMarbleLevel *level = [[[CMMarbleLevel alloc]initWithDictionary:levelDict]autorelease];
      level.baseURL = self.baseURL;
      [mylevelList addObject:level];
    }else{
      NSLog(@"Level with ID %@ not found",levelId);
    }

  }


//	NSArray * levelDataList = [dict objectForKey:@"levels"];
//	for (NSDictionary *levelDict in levelDataList) {
//    CMMarbleLevel *level =[[[CMMarbleLevel alloc]initWithDictionary:levelDict]autorelease];	
//		level.baseURL = self.baseURL;
//		[mylevelList addObject:level];
//	}
	return mylevelList;
}

- (id) initWithURL:(NSURL*) levelSetURL
{
	if((self = [super init])){
		self.baseURL = levelSetURL;
		NSBundle *myBundle = [NSBundle bundleWithURL:levelSetURL];
		NSURL * levelsetDescriptionURL = [myBundle URLForResource:@"LevelSet" withExtension:@"plist"];
		NSData *propListData = [NSData dataWithContentsOfURL:levelsetDescriptionURL];
		NSError *error;
		NSDictionary *propList = (NSDictionary*)[NSPropertyListSerialization propertyListWithData:propListData
																																											options:kCFPropertyListImmutable 
																																											 format:nil error:&error];

		self.levelList = [self loadLevelsFromDictionary:propList];
	}
	return self;
}

- (void) dealloc
{
	self.baseURL    = nil;
	self.levelList  = nil;
	[super dealloc];
}

- (void) releaseLevelData
{
	for (CMMarbleLevel *level in self.levelList) {
    [level releaseLevelData];
	}
}
@end
