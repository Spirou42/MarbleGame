//
//  AppDelegate.h
//  MarbleGame
//
//  Created by Carsten Müller on 7/30/13.
//  Copyright Carsten Müller 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "CMMarbleLevelSet.h"

// Added only for iOS 6 support
@interface MyNavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface MarbleGameAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	MyNavigationController *navController_;
	
	CCDirectorIOS	*director_;							// weak ref
  
  CMMarbleLevelSet* _levelSet;
  NSArray           *_marbleSets;
	NSPersistentStoreCoordinator 	*_persistentStoreCoordinator;
	NSManagedObjectModel					*_managedObjectModel;
	NSManagedObjectContext				*_managedObjectContext;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (readonly) MyNavigationController *navController;
@property (readonly) CCDirectorIOS *director;
@property (readonly) BOOL isPad1;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (nonatomic, retain) CMMarbleLevelSet* levelSet;
@property (nonatomic, retain) NSArray *marbleSets;

- (NSURL *)applicationStoreDirectory;
@end
