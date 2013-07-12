/*
 * CCControlSwitchTest.m
 *
 * Copyright (c) 2012 Yannick Loriot
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCControlSwitchTest.h"

@interface CCControlSwitchTest ()
@property (nonatomic, strong) CCLabelTTF        *displayValueLabel;
@property (nonatomic, strong) CCControlSwitch   *switchControl;

/** Creates and returns a new CCControlSwitch. */
- (CCControlSwitch *)makeControlSwitch;

/** Callback for the change value. */
- (void)valueChanged:(CCControlSwitch *)sender;

@end

@implementation CCControlSwitchTest
@synthesize displayValueLabel;
@synthesize switchControl;
- (void)dealloc
{
    [displayValueLabel  release];
    [switchControl      release];
    
    [super              dealloc];
}

- (id)init
{
	if ((self = [super init]))
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCNode *layer               = [CCNode node];
        layer.position              = ccp (screenSize.width / 2, screenSize.height / 2);
        [self addChild:layer z:1];
        
        double layer_width = 0;
        
        // Add the black background for the text
        CCScale9Sprite *background  = [CCScale9Sprite spriteWithFile:@"buttonBackground.png"];
        background.contentSize      = CGSizeMake(80, 50);
        background.position         = ccp(layer_width + background.contentSize.width / 2.0f, 0);
        [layer addChild:background];
        
        layer_width += background.contentSize.width;
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        self.displayValueLabel      = [CCLabelTTF labelWithString:@"on" fontName:@"HelveticaNeue-Bold" fontSize:30];
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
        self.displayValueLabel      = [CCLabelTTF labelWithString:@"on" fontName:@"Marker Felt" fontSize:30];
#endif
        displayValueLabel.position  = background.position;
        [layer addChild:displayValueLabel];
        
        // Create the switch
        self.switchControl          = [self makeControlSwitch];
        switchControl.position      = ccp (layer_width + 10 + switchControl.contentSize.width / 2, 0);
        switchControl.on            = NO;
        [layer addChild:switchControl];

        [switchControl addTarget:self action:@selector(valueChanged:) forControlEvents:CCControlEventValueChanged];
        
        // Set the layer size
        layer.contentSize           = CGSizeMake(layer_width, 0);
        layer.anchorPoint           = ccp (0.5f, 0.5f);
	}
	return self;
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [switchControl setOn:YES animated:YES];
}

#pragma mark -
#pragma mark CCControlSwitchTest Public Methods

#pragma mark CCControlSwitchTest Private Methods

- (CCControlSwitch *)makeControlSwitch
{
    return [CCControlSwitch switchWithMaskSprite:[CCSprite spriteWithFile:@"switch-mask.png"] 
                                        onSprite:[CCSprite spriteWithFile:@"switch-on.png"]
                                       offSprite:[CCSprite spriteWithFile:@"switch-off.png"]
                                     thumbSprite:[CCSprite spriteWithFile:@"switch-thumb.png"]
                                         onLabel:[CCLabelTTF labelWithString:@"On" fontName:@"Arial-BoldMT" fontSize:16]
                                        offLabel:[CCLabelTTF labelWithString:@"Off" fontName:@"Arial-BoldMT" fontSize:16]];
}

- (void)valueChanged:(CCControlSwitch *)sender
{
    if ([sender isOn])
    {
        displayValueLabel.string    = @"On";
    } else
    {
        displayValueLabel.string    = @"Off";
    }
}

@end
