//
//  MarbleGameConfig.h
//  MarbleGame
//
//  Created by Carsten Müller on 7/2/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#ifndef MarbleGame_MarbleGameConfig_h
#define MarbleGame_MarbleGameConfig_h

//////////////////////////////////////////////////
#pragma mark - 
#pragma mark GAME Configs
//////////////////////////////////////////////////

#define MAX_DIFFERENT_MARBLES 9

#define DEFAULT_LEVELSET_NAME @"Default Levels"
#define DEFAULT_LEVELSET_EXTENSION @"bundle"
#define DEFAULT_MARBLE_THEME @"attraktor"

//////////////////////////////////////////////////
#pragma mark Physics

#define MARBLE_FRICTION   .9
#define MARBLE_ELASTICITY .2
#define BORDER_FRICTION   1.0f
#define BORDER_ELASTICITY 0.1f

#ifdef __CC_PLATFORM_MAC
#define SPACE_GRAVITY     981.00f
#else
#define SPACE_GRAVITY     (981.00f * 1.0f)
#endif

#define MARBLE_MASS       		20.0f
#define MARBLE_RADIUS 				20.0f
#define MARBLE_DESTROY_TIME 		.1
#define MARBLE_CREATE_DELAY 		.5
#define MARBLE_CREATE_TIME 			.1
#define MARBLE_GROOVE_Y 			700

//////////////////////////////////////////////////
#pragma mark  SCORE SETTINGS

#define MARBLE_THROW_SCORE 				(-1.0f)
#define MARBLE_HIT_SCORE					(3.0f)
#define MARBLE_COMBO_MULTIPLYER 	(10.0f)
#define MARBLE_MULTY_MUTLIPLYER		(8.0f)
#define MARBLE_SPEZIAL_NICE				(2.0f)
#define MARBLE_SPEZIAL_RESPECT		(3.0f)
#define MARBLE_SPEZIAL_PERFECT		(4.0f)
#define MARBLE_SPEZIAL_TRICK			(5.0f)
#define MARBLE_SPEZIAL_LUCKY			(6.0f)




#define DEFAULT_COMBO_EFFECT_FILE @"combo.png"
#define DEFAULT_MULTI_EFFECT_FILE @"multi.png"

/// transition / Action parameters

#define DEFAULT_COMBO_MOVE_DURATION (1.5f)
#define DEFAULT_COMBO_SCALE_DURATION (1.5f)
#define DEFAULT_COMBO_SCALE_TARGET (.1f)

#define DEFAULT_MARBLE_SLOT_MOVE_TIME (1.0f)

//////////////////////////////////////////////////
#pragma mark -
#pragma mark UI Definitions

#define kCMMarbleGlossMapShader @"marble_glossmap_shader"

// definitions for the default UI elements

#define DEFAULT_BACKGROUND_IMAGE 				@"MainMenu-Background.png"
#define MAIN_MENU_OVERLAY 							@"MainMenu-Overlay.png"

// normal Buttons
#define DEFAULT_UI_PLIST 								@"GameUI.plist"
#define NORMAL_BUTTON_BACKGROUND 				@"Button-Normal"
#define ACTIVE_BUTTON_BACKGROUND 				@"Button-Active"
#define BUTTON_BACKGROUND_CAPS 					CGRectMake(8,8,77,23)

// DropDown Buttons
#define DEFAULT_DDBUTTON_BACKGROUND 		@"DDButton-Normal"
#define DDBUTTON_BACKGROUND_CAPS 				CGRectMake(8,8,77,23)
#define DEFAULT_DDMENU_BACKGROUND 			@"DDMenu-Background"
#define DDMENU_BACKGROUND_CAPS 					CGRectMake(9,9,142,103)
#define DEFAULT_DDBUTTON_GLYPH 					@"DDButton-Glyph"
//#define DEFAULT_DDMENUITM_BACKGROUND 		@"GlassDDItemBackground"
#define DDMENUITM_BACKGROUND_CAPS 			CGRectMake(1,1,96,29)

#define MENU_BACKGROUND_PLATE						@"Menu-Background.png"


// definition for Sounds

#define DEFAULT_BACKGROUND_MUSIC						@"MarbleGame-Background.mp3"
#define DEFAULT_MARBLE_KLICK								@"marbleKlick.mp3"
//////////////////////////////////////////////////
#pragma mark Fonts

#define DEFAULT_FONT @"RockWell24-OutlineButton.fnt"
#define DEFAULT_BUTTON_FONT DEFAULT_FONT
#define DEFAULT_BUTTON_TITLE_COLOR ccc3(250, 250, 250)
#define SELECTED_BUTTON_TITLE_COLOR ccc3(255,200, 0)
#define DEFAULT_BUTTON_SIZE CGSizeMake(150,50)
#define DEFAULT_BUTTON_TITLESIZE CGSizeMake(0,0)

#define DEFAULT_MENU_FONT @"RockWell30-OutlineMenuTitle.fnt"

#define DEFAULT_MENU_TITLE_COLOR ccc3(250, 250, 250)
#define SELECTED_MENU_TITLE_COLOR ccc3(255,200, 0)
#define DEFAULT_MENU_TITLESIZE DEFAULT_BUTTON_TITLESIZE

//////////////////////////////////////////////////
#pragma mark Layers

#define BACKGROUND_LAYER 			(-1)

#define MARBLE_LAYER 					(1)
#define FOREGROUND_LAYER 			(2)

#define OVERLAY_LAYER 				(5)
#define OVERLAY_LABEL_LAYER		(6)

// legacy, will die
#define BUTTON_LAYER 					(9)
#define MENU_LAYER 						(10)

#pragma mark -
#pragma mark SYSTEM replacement Types

#ifdef __CC_PLATFORM_MAC
#define CMEvent NSEvent
#define CMAppDelegate (MarbleGameAppDelegate*)[NSApp delegate]
#define CMSharedApplication ([NSApplication sharedApplication])
#else
#define CMEvent UIEvent
#define CMAppDelegate (MarbleGameAppDelegate*)[[UIApplication sharedApplication] delegate]
#define CMSharedApplication ([UIApplication sharedAplication])
#endif



#endif
