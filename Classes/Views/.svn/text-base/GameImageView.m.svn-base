//
//  GameImageViewController.m
//  BabyAnimals
//
//  Created by Susan Surapruik on 9/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameImageView.h"
#import "Constants.h"

@implementation GameImageView

@synthesize _showSpeckles;

- (id)initWithCoder:(NSCoder*)coder {
	if ((self = [super initWithCoder:coder])) {
		[self initializeMe];
	}
	return self;
}

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self != nil) {
		[self initializeMe];
	}
	return self;
}

- (void) initializeMe {
	UIImage *img0, *img1;
	
//	_iPhoneDevice = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad;
	
	self.backgroundColor = [UIColor whiteColor];
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_contextRef = CGBitmapContextCreate(NULL, self.bounds.size.width, self.bounds.size.height, 8, 4 * self.bounds.size.width, colorSpace, kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(colorSpace);
	 
	_layerRef = CGLayerCreateWithContext(_contextRef, self.bounds.size, NULL);
	CGContextRef layerContext = CGLayerGetContext(_layerRef);
	CGContextSetLineWidth(layerContext, 10.0);
	CGContextSetLineCap(layerContext, kCGLineCapRound);
	CGContextSetRGBStrokeColor(layerContext, 1.0, 0.0, 0.0, 1.0);
	
	_showSpeckles = YES;
	
//	if (_iPhoneDevice) {
//		img0 = [NSString stringWithFormat:@"%@.png", kImage_Speckle];
//	} else {
		img0 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_iPad.png", kImage_Speckle]];
//	}
	_speckle = CGImageRetain(img0.CGImage);
	
//	if (_iPhoneDevice) {
//		img1 = [NSString stringWithFormat:@"%@.png", kImage_Paper];
//	} else {
		img1 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_iPad.png", kImage_Paper]];
//	}
	_paper = CGImageRetain(img1.CGImage);
}

-(void)drawInContext:(CGContextRef)context {
	// Expects a Lower-Left coordinate system, so we flip the coordinate system before drawing.
	CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGImageRef image = CGBitmapContextCreateImage(_contextRef);
	CGContextDrawImage(context, [self bounds], image);
	CGImageRelease(image);
	CGContextDrawLayerInRect(context, [self bounds], _layerRef);
	
	if (_imageFileName) {
		CGContextSetBlendMode(context, kCGBlendModeCopy);
		CGContextDrawImage(context, self.bounds, _image);
	}
	if (_showSpeckles) {
		CGContextSetBlendMode(context, kCGBlendModeScreen);
		CGContextDrawImage(context, self.bounds, _speckle);
	}
	CGContextSetBlendMode(context, kCGBlendModeMultiply);
	CGContextDrawImage(context, self.bounds, _paper);
	
}

- (void) drawFromPoint:(CGPoint)start toPoint:(CGPoint)end {
	CGContextRef layerContext = CGLayerGetContext(_layerRef);
	CGContextBeginPath(layerContext);
	CGContextMoveToPoint(layerContext, start.x, start.y);
	CGContextAddLineToPoint(layerContext, end.x, end.y);
	CGContextStrokePath(layerContext);
	[self setNeedsDisplay];
}

- (void)dealloc {
	CGImageRelease(_image);
	CGImageRelease(_speckle);
	CGImageRelease(_paper);
	
	CGLayerRelease(_layerRef);
	CGContextRelease(_contextRef);
	
	[_imageFileName release];

    [super dealloc];
}



- (void) set_imageFileName:(NSString*)newImageFileName {
	NSString *imageFileName, *imagePath;
	UIImage *img0;
	
	if (_imageFileName) {
		[_imageFileName release];
		CGImageRelease(_image);
	}
	
	_imageFileName = [[NSString alloc] initWithString:newImageFileName];
	
//	if (_iPhoneDevice) {
//		imageFileName = newImageFileName;
//	} else {
		imageFileName = [NSString stringWithFormat:@"%@_iPad", newImageFileName];
//	}
	
	imagePath = [[NSBundle mainBundle] pathForResource:imageFileName ofType:@"png"];
	img0 = [UIImage imageWithContentsOfFile:imagePath];
	_image = CGImageRetain(img0.CGImage);
}
- (NSString*) _imageFileName {
	return _imageFileName;
}

@end