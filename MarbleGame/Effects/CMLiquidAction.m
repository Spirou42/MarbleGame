//
//  CMLiquidAction.m
//  MarbleGame
//
//  Created by Carsten Müller on 9/13/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMLiquidAction.h"
#import "cocos2d.h"


@implementation CMLiquidAction
@synthesize textureSize = textureSize_;

-(CCGridBase*) grid
{
	if (CGSizeEqualToSize(self.textureSize, CGSizeZero) ) {
		self.textureSize = [[CCDirector sharedDirector] winSizeInPixels];
	}
	unsigned long POTWide = ccNextPOT(self.textureSize.width);
	unsigned long POTHigh = ccNextPOT(self.textureSize.height);
#ifdef __CC_PLATFORM_IOS
	CCGLView *glview = (CCGLView*)[[CCDirector sharedDirector] view];
	NSString *pixelFormat = [glview pixelFormat];
	
	CCTexture2DPixelFormat format = [pixelFormat isEqualToString: kEAGLColorFormatRGB565] ? kCCTexture2DPixelFormat_RGB565 : kCCTexture2DPixelFormat_RGBA8888;
#elif defined(__CC_PLATFORM_MAC)
	CCTexture2DPixelFormat format = kCCTexture2DPixelFormat_RGBA8888;
#endif
	int bpp = ( format == kCCTexture2DPixelFormat_RGB565 ? 2 : 4 );
	void *data = calloc((size_t)(POTWide * POTHigh * bpp), 1);
	if( ! data ) {
		CCLOG(@"cocos2d: CCGrid: not enough memory");
		[self release];
		return nil;
	}
	CCTexture2D *texture = [[CCTexture2D alloc] initWithData:data pixelFormat:format pixelsWide:POTWide pixelsHigh:POTHigh contentSize:self.textureSize];
	free( data );
//	CCTexture2D* newTexture = [CCTexture2D]
	CCGridBase *result = [CCGrid3D gridWithSize:self.gridSize texture:texture flippedTexture:NO];
	return result;
}
@end

@implementation CMTwirlAction
@synthesize textureSize = textureSize_;

-(CCGridBase*) grid
{
	if (CGSizeEqualToSize(self.textureSize, CGSizeZero) ) {
		self.textureSize = [[CCDirector sharedDirector] winSizeInPixels];
	}
	unsigned long POTWide = ccNextPOT(self.textureSize.width);
	unsigned long POTHigh = ccNextPOT(self.textureSize.height);
#ifdef __CC_PLATFORM_IOS
	CCGLView *glview = (CCGLView*)[[CCDirector sharedDirector] view];
	NSString *pixelFormat = [glview pixelFormat];
	
	CCTexture2DPixelFormat format = [pixelFormat isEqualToString: kEAGLColorFormatRGB565] ? kCCTexture2DPixelFormat_RGB565 : kCCTexture2DPixelFormat_RGBA8888;
#elif defined(__CC_PLATFORM_MAC)
	CCTexture2DPixelFormat format = kCCTexture2DPixelFormat_RGBA8888;
#endif
	int bpp = ( format == kCCTexture2DPixelFormat_RGB565 ? 2 : 4 );
	void *data = calloc((size_t)(POTWide * POTHigh * bpp), 1);
	if( ! data ) {
		CCLOG(@"cocos2d: CCGrid: not enough memory");
		[self release];
		return nil;
	}
	CCTexture2D *texture = [[CCTexture2D alloc] initWithData:data pixelFormat:format pixelsWide:POTWide pixelsHigh:POTHigh contentSize:self.textureSize];
	free( data );
	//	CCTexture2D* newTexture = [CCTexture2D]
	CCGridBase *result = [CCGrid3D gridWithSize:self.gridSize texture:texture flippedTexture:NO];
	return result;
}
@end
