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
#import "CMMarbleLevelSet.h"
#import "MarbleGameAppDelegate+GameDelegate.h"
#import "CMMarblePlayer.h"
#import "CMMPSettings.h"

@implementation MarbleGameAppDelegate
@synthesize window=window_, glView=glView_,levelSet=_levelSet, marbleSets=_marbleSets;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;




- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	ccDrawInit();
	// enable FPS and SPF
	[director setDisplayStats:YES];
	
	// connect the OpenGL view with the director
	[director setView:glView_];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_AutoScale];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:YES];
	
	// Center main window
	[window_ center];
  
  [self initializeMarbleGame];
  
	[director runWithScene:[CMMarbleMainMenuScene node]];
	
//#if __CC_PLATFORM_MAC
	if (self.currentPlayer.settings.wasFullScreen) {
    [self.window toggleFullScreen:nil];
//		CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
//		[director setFullScreen: YES ];

	}
//#endif
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

//- (IBAction)toggleFullScreen: (id)sender
//{
//	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
//	[director setFullScreen: ! [director isFullScreen] ];
//	self.currentPlayer.settings.wasFullScreen = [director isFullScreen];
//	NSError *error;
//	[self.managedObjectContext save:&error];
//}

- (void) windowDidEnterFullScreen:(NSNotification *)notification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
  self.currentPlayer.settings.wasFullScreen = YES;
  NSError *error;
  [self.managedObjectContext save:&error];
}

- (void) windowDidExitFullScreen:(NSNotification *)notification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
  self.currentPlayer.settings.wasFullScreen = NO;
  NSError *error;
  [self.managedObjectContext save:&error];
}

#pragma mark - Properties

- (NSInteger) simulationSteps
{
	return 1;
}

#pragma mark -
#pragma mark CoreData
// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "org.attraktor.coreDataBla" in the user's Application Support directory.
- (NSURL *)applicationStoreDirectory
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	return [appSupportURL URLByAppendingPathComponent:@"org.attraktor.MarbleGame"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
	if (self->_managedObjectModel) {
		return self->_managedObjectModel;
	}
	
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CMMarbleGameStatistics" withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator) {
		return _persistentStoreCoordinator;
	}
	
	NSManagedObjectModel *mom = [self managedObjectModel];
	if (!mom) {
		NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
		return nil;
	}
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *applicationFilesDirectory = [self applicationStoreDirectory];
	NSError *error = nil;
	
	NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
	
	if (!properties) {
		BOOL ok = NO;
		if ([error code] == NSFileReadNoSuchFileError) {
			ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
		}
		if (!ok) {
			[[NSApplication sharedApplication] presentError:error];
			return nil;
		}
	} else {
		if (![[properties objectForKey:NSURLIsDirectoryKey ] boolValue]) {
			// Customize and localize this error.
			NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
			
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			[dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
			error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
			
			[[NSApplication sharedApplication] presentError:error];
			return nil;
		}
	}
	
	NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"CMMarbleGameStatistics.storedata"];
	NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
	if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
		[[NSApplication sharedApplication] presentError:error];
		
		// try to remove the old store
		[fileManager removeItemAtURL:url error:&error];
		
		if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
				[[NSApplication sharedApplication] presentError:error];
			[coordinator release];
				return nil;
		}
	}
	_persistentStoreCoordinator = coordinator;
	
	return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
	if (_managedObjectContext) {
		return _managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (!coordinator) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
		[dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
		NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
		[[NSApplication sharedApplication] presentError:error];
		return nil;
	}
	_managedObjectContext = [[NSManagedObjectContext alloc] init];
	[_managedObjectContext setPersistentStoreCoordinator:coordinator];
	
	return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
	return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
	NSError *error = nil;
	
	if (![[self managedObjectContext] commitEditing]) {
		NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
	}
	
	if (![[self managedObjectContext] save:&error]) {
		[[NSApplication sharedApplication] presentError:error];
	}
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	// Save changes in the application's managed object context before the application terminates.
	
	if (!_managedObjectContext) {
		return NSTerminateNow;
	}
	
	if (![[self managedObjectContext] commitEditing]) {
		NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
		return NSTerminateCancel;
	}
	
	if (![[self managedObjectContext] hasChanges]) {
		return NSTerminateNow;
	}
	
	NSError *error = nil;
	if (![[self managedObjectContext] save:&error]) {
		
		// Customize this code block to include application-specific recovery steps.
		BOOL result = [sender presentError:error];
		if (result) {
			return NSTerminateCancel;
		}
		
		NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
		NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
		NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
		NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:question];
		[alert setInformativeText:info];
		[alert addButtonWithTitle:quitButton];
		[alert addButtonWithTitle:cancelButton];
		
		NSInteger answer = [alert runModal];
		[alert release];
		if (answer == NSAlertAlternateReturn) {
			return NSTerminateCancel;
		}
	}
	
	return NSTerminateNow;
}


@end
