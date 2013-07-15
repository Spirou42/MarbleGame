//
//  SettingScene.h
//  CocosTest1
//
//  Created by Carsten Müller on 6/29/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCScene.h"
#import "CCControlExtension.h"
#define USE_DEFAULT_BUTTON_FOR_MENU 1

@interface CMMarbleSettingsScene : CCNodeRGBA
@property (nonatomic,assign) CCControlButton *popupButton;
@end
