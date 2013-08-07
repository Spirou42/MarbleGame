//
//  MarbleGameConfig.h
//  MarbleGame
//
//  Created by Carsten Müller on 7/2/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#ifndef MarbleGame_MarbleGameConfig_h
#define MarbleGame_MarbleGameConfig_h

#define DEFAULT_LEVELSET_NAME @"DummyLevels"
#define DEFAULT_LEVELSET_EXTENSION @"levelset"


#define DEFAULT_FONT @"RockWell24-OutlineButton.fnt"
#define DEFAULT_BUTTON_FONT DEFAULT_FONT
#define DEFAULT_BUTTON_FONT_SIZE 18
#define DEFAULT_BUTTON_TITLE_COLOR ccc3(250, 250, 250)
#define SELECTED_BUTTON_TITLE_COLOR ccc3(255,200, 0)
#define DEFAULT_BUTTON_SIZE CGSizeMake(150,40)
#define DEFAULT_BUTTON_TITLESIZE CGSizeMake(0,0)

#define DEFAULT_MENU_FONT DEFAULT_FONT
#define DEFAULT_MENU_FONT_SIZE 30
#define DEFAULT_MENU_TITLE_COLOR ccc3(250, 250, 250)
#define SELECTED_MENU_TITLE_COLOR ccc3(255,200, 0)
#define DEFAULT_MENU_TITLESIZE DEFAULT_BUTTON_TITLESIZE


// default UI element definitions


#define DEFAULT_BACKGROUND_IMAGE @"MainMenu-Background.png"
#define MAIN_MENU_OVERLAY @"MainMenu-Overlay.png"

#define DEFAULT_UI_PLIST @"GlassButtons.plist"
#define NORMAL_BUTTON_BACKGROUND @"GlassButtonNormal"
#define ACTIVE_BUTTON_BACKGROUND @"GlassButtonHover"
#define BUTTON_BACKGROUND_CAPS CGRectMake(9,9,80,27)

#define DEFAULT_DDBUTTON_BACKGROUND @"GlassDDBackground"
#define DDBUTTON_BACKGROUND_CAPS CGRectMake(9,9,143,21)

#define DEFAULT_DDMENU_BACKGROUND @"GlassDDMenuBackground"
#define DDMENU_BACKGROUND_CAPS CGRectMake(9,9,142,103)

#define DEFAULT_DDBUTTON_GLYPH @"GlassDDArrow"
#define DEFAULT_DDMENUITM_BACKGROUND @"GlassDDItemBackground"
#define DDMENUITM_BACKGROUND_CAPS CGRectMake(1,1,96,29)


#define kCMMarbleGlossMapShader @"marble_glossmap_shader"



/// Definition of default physics parameters

#define MARBLE_FRICTION   .9
#define MARBLE_ELASTICITY .2
#define BORDER_FRICTION   1.0f
#define BORDER_ELASTICITY 0.1f

#ifdef __CC_PLATFORM_MAC
  #define SPACE_GRAVITY     981.00f
#else
  #define SPACE_GRAVITY     (981.00f * 1.0f)
#endif

#define MARBLE_MASS       20.0f
#define MARBLE_RADIUS 		20
#define MARBLE_DESTROY_TIME .1
#define MARBLE_CREATE_DELAY .5
#define MARBLE_CREATE_TIME .1
#define MARBLE_GROOVE_Y 600

#pragma mark -
#pragma mark SYSTEM replacement Types

#ifdef __CC_PLATFORM_MAC
#define CMEvent NSEvent
#define CMAppDelegate (MarbleGameAppDelegate*)[NSApp delegate]
#else
#define CMEvent UIEvent
#define CMAppDelegate (MarbleGameAppDelegate*)[[UIApplication sharedApplication] delegate]
#endif


/// SCORE SETTINGS

#define MARBLE_THROW_SCORE 				(-1.0f)
#define MARBLE_HIT_SCORE					(2.0f)
#define MARBLE_COMBO_MULTIPLYER 	(10.0f)
#define MARBLE_MULTY_MUTLIPLYER		(8.0f)
#define MARBLE_SPEZIAL_NICE				(2.0f)
#define MARBLE_SPEZIAL_RESPECT		(3.0f)
#define MARBLE_SPEZIAL_PERFECT		(4.0f)
#define MARBLE_SPEZIAL_TRICK			(5.0f)
#define MARBLE_SPEZIAL_LUCKY			(6.0f)

#endif
