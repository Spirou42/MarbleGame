//
//  CMMableLevelSelectMenu.h
//  MarbleGame
//
//  Created by Carsten Müller on 10/7/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMEventEatingLayer.h"

@interface CMMarbleLevelSelectMenu : CMEventEatingLayer

@property (nonatomic,assign) CGRect contentRect;
@property (nonatomic,assign) CGSize gridSize;
@end
