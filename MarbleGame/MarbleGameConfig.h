//
//  MarbleGameConfig.h
//  MarbleGame
//
//  Created by Carsten Müller on 7/2/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#ifndef MarbleGame_MarbleGameConfig_h
#define MarbleGame_MarbleGameConfig_h


#define DEFAULT_FONT @"Helvetica Neue Light"
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


#define DEFAULT_BACKGROUND_IMAGE @"Background-New.png"

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
#define SPACE_GRAVITY     981.0f
#define MARBLE_MASS       20.0f
#define MARBLE_RADIUS 		20
#define MARBLE_DESTROY_TIME .1


#endif
