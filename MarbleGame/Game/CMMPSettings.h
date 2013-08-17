//
//  CMMPSettings.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/17/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CMMarblePlayer;

@interface CMMPSettings : NSManagedObject

@property (nonatomic, retain) NSString * marbleTheme;
@property (nonatomic) float soundVolume;
@property (nonatomic) float musicVolume;
@property (nonatomic, retain) NSString * scoreMode;
@property (nonatomic, retain) CMMarblePlayer *player;

@end
