#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "DrawEAGLView.h"

@interface DrawEAGLView (private)

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL createSurface;
- (void) destroySurface;

@end

@implementation DrawEAGLView

@synthesize _previousDrawnImage, _paperView;

+ (Class) layerClass {
	return [CAEAGLLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self != nil) {
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*)[self layer];
		
		eaglLayer.opaque = YES;
		
		[eaglLayer setDrawableProperties:@{kEAGLDrawablePropertyRetainedBacking: @YES,
										  kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8}];
		
		
		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if(_context == nil || ![EAGLContext setCurrentContext:_context]) {
			[self release];
			return nil;
		}
		
		[self initializeView];
	}
	return self;
}

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (instancetype)initWithCoder:(NSCoder*)coder {
	if ((self = [super initWithCoder:coder])) {
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*)[self layer];
		
		eaglLayer.opaque = YES;
		
		[eaglLayer setDrawableProperties:@{kEAGLDrawablePropertyRetainedBacking: @YES,
										  kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8}];
		
		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if(_context == nil || ![EAGLContext setCurrentContext:_context]) {
			[self release];
			return nil;
		}
		
		[self initializeView];
	}
	
	return self;
}

- (void) initializeView {
	NSString *brushFileName, *paperFileName;
	
//	_iPhoneDevice = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad;
	
//	if (_iPhoneDevice) {
//		_viewWidth = 480;
//		_viewHeight = 320;
//		brushFileName = [NSString stringWithFormat:@"%@.png", kImage_Brush];
//		paperFileName = [NSString stringWithFormat:@"%@.png", kImage_Paper];
//	} else {
		_viewWidth = 1024;
		_viewHeight = 768;
		brushFileName = [NSString stringWithFormat:@"%@_iPad.png", kImage_Brush];
		paperFileName = [NSString stringWithFormat:@"%@_iPad.png", kImage_Paper];
//	}
	
	//Set up OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	glOrthof(0, self.bounds.size.width, 0, self.bounds.size.height, -1, 1);
	glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glDisable(GL_DITHER);
	
	glEnable(GL_BLEND);
	
	_clearFirst = YES;
	_firstDraw = YES;
	
	_imageFileName = [[NSString alloc] initWithString:@""];
	
	_brush = [[Texture2D alloc] initWithImage: [UIImage imageNamed:brushFileName]];
	
	_previousDrawnImage = [[UIImageView alloc] initWithFrame:self.bounds];
	_previousDrawnImage.hidden = YES;
	_previousDrawnImage.backgroundColor = [UIColor clearColor];
	_previousDrawnImage.opaque = NO;
	[self addSubview:_previousDrawnImage];
	
	// ADDED FOR ERASER /////////////////////////////////////////////////
	CGImageRef paperImageRef = [UIImage imageNamed:paperFileName].CGImage;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	unsigned int width = CGImageGetWidth(paperImageRef);
	unsigned int height = CGImageGetHeight(paperImageRef);
	unsigned int bitsPerComponent = CGImageGetBitsPerComponent(paperImageRef); // 8
//	unsigned int bytesPerRow = CGImageGetBytesPerRow(paperImageRef);	// width * 4;
	unsigned int bytesPerRow = width * 4;

	NSInteger myDataLength = width * height * 4;
	UInt8 *rawData = malloc(myDataLength);
	
	CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorSpace);
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	CGContextDrawImage(context, CGRectMake(0,0,width,height), paperImageRef);
	CGContextRelease(context);
	CGImageRelease(paperImageRef);
	
	int byteIndex = 0;
	unsigned int r, g, b, a, rgbInt;
	for(int y = 0; y < _viewHeight; y++) {
		for(int x = 0; x < _viewWidth; x++) {
			r = rawData[byteIndex];
			g = rawData[byteIndex + 1];
			b = rawData[byteIndex + 2];		
			
			rgbInt = (r << 16) + (g << 8) + b;
			
			a = 255 - ceilf(rgbInt * 255 / 16777215);
			
			rawData[byteIndex] = 0;
			rawData[byteIndex + 1] = 0;
			rawData[byteIndex + 2] = 0;
			rawData[byteIndex + 3] = a;

			byteIndex += 4;
		}
	}
	 
//	CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, rawData, myDataLength, releaseDataCallback);
	CGDataProviderRef ref = CGDataProviderCreateWithData(rawData, rawData, myDataLength, releaseDataCallback);
	CGImageRef iref = CGImageCreate(width,height,bitsPerComponent,32,bytesPerRow,CGColorSpaceCreateDeviceRGB(),kCGBitmapByteOrderDefault | kCGImageAlphaLast,ref,NULL,true,kCGRenderingIntentDefault);
	
	UIImage *image = [[UIImage alloc] initWithCGImage:iref];
	
	CGDataProviderRelease(ref);
	CGImageRelease(iref);	
	
	_paperView = [[UIImageView alloc] initWithFrame:self.bounds];
	_paperView.backgroundColor = [UIColor clearColor];
	_paperView.opaque = NO;
	_paperView.image = image;
	[self addSubview:_paperView];
	
	_image = [[UIImageView alloc] initWithFrame:self.bounds];
	_image.backgroundColor = [UIColor clearColor];
	_image.opaque = NO;
	[self addSubview:_image];
}


- (void) layoutSubviews {
	[self destroySurface];
	[self createSurface];
	
	if (_clearFirst) {
		[self clearDrawnPoints];
		_clearFirst = NO;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"EAGLEViewLoaded" object:self];
	}
}

- (BOOL) createSurface {
	CAEAGLLayer*			eaglLayer = (CAEAGLLayer*)[self layer];
	CGSize					newSize;
	
	if(![EAGLContext setCurrentContext:_context]) {
		return NO;
	}
	
	newSize = [eaglLayer bounds].size;
	newSize.width = roundf(newSize.width);
	newSize.height = roundf(newSize.height);
	
	glGenRenderbuffersOES(1, &_renderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderbuffer);
	
	glGenFramebuffersOES(1, &_framebuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, _framebuffer);
	
	[_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:eaglLayer];
	
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _renderbuffer);
	
	// need a depth buffer, so we'll create and attach one via another renderbuffer.
	glGenRenderbuffersOES(1, &_depthBuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _depthBuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, newSize.width, newSize.height);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, _depthBuffer);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

- (void) destroySurface {
	glDeleteFramebuffersOES(1, &_framebuffer);
	_framebuffer = 0;
	glDeleteRenderbuffersOES(1, &_renderbuffer);
	_renderbuffer = 0;
	
	if(_depthBuffer) {
		glDeleteRenderbuffersOES(1, &_depthBuffer);
		_depthBuffer = 0;
	}
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void) clearDrawnPoints {
	[EAGLContext setCurrentContext:_context];
	//Clear the buffer
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, _framebuffer);
	
	glClear(GL_COLOR_BUFFER_BIT);
	glClearColor(1.0, 1.0, 1.0, 1.0);
	
	//Display the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderbuffer);
	[_context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void) changeLineColorR:(float)r G:(float)g B:(float)b {
	glColor4f(r, g, b, 1.0);
}

- (void) drawFromPoint:(CGPoint)start toPoint:(CGPoint)end {
	[EAGLContext setCurrentContext:_context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, _framebuffer);
	
	[_brush paintTextureFromPoint:start toPoint:end];
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderbuffer);
	[_context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)dealloc {
	[self destroySurface];
	
	if([EAGLContext currentContext] == _context) {
		[EAGLContext setCurrentContext:nil];
	}
	[_context release];
	_context = nil;
	
	[_paperView release];
	[_image release];
	[_previousDrawnImage release];

	[_brush release];
	
	[_imageFileName release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Save/Restore Animation Data

- (NSData*) convertImageToData {
	GLubyte *buffer = (GLubyte *) malloc(_viewHeight*_viewWidth*4);
	glReadPixels(0,0,_viewWidth,_viewHeight,GL_RGBA,GL_UNSIGNED_BYTE,buffer);
//	CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, buffer, _viewHeight*_viewWidth*4, NULL);
	CGDataProviderRef ref = CGDataProviderCreateWithData(buffer, buffer, _viewHeight*_viewWidth*4, releaseDataCallback);
	
	//unsigned char buffer[_viewHeight*_viewWidth*4];
	//glReadPixels(0,0,_viewWidth,_viewHeight,GL_RGBA,GL_UNSIGNED_BYTE,&buffer);
	//CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, &buffer, _viewHeight*_viewWidth*4, NULL);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGImageRef iref = CGImageCreate(_viewWidth,_viewHeight,8,32,_viewWidth*4,colorSpace,kCGBitmapByteOrderDefault,ref,NULL,true,kCGRenderingIntentDefault);
	
	size_t width         = CGImageGetWidth(iref);
	size_t height        = CGImageGetHeight(iref);
//	size_t length        = width*height*4;
//	uint32_t *pixels     = (uint32_t *)malloc(length);
//	CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width*4, CGImageGetColorSpace(iref), kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrderDefault);
	CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width*4, CGImageGetColorSpace(iref), kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrderDefault);
	
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), iref);
	
	CGImageRef outputRef = CGBitmapContextCreateImage(context);
	UIImage *drawingImage = [UIImage imageWithCGImage:outputRef];
	
	// set the previous drawn image so it will be there for the flip
	_previousDrawnImage.image = drawingImage;
	_previousDrawnImage.hidden = NO;
	
	CGDataProviderRelease(ref);
	CGColorSpaceRelease(colorSpace);
	CGImageRelease(iref);
	CGImageRelease(outputRef);
	CGContextRelease(context);
	
//	free(pixels);
	
	return UIImagePNGRepresentation(drawingImage);
}

- (void) drawSavedImageData:(NSData*)imageData {
	[EAGLContext setCurrentContext:_context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, _framebuffer);
	
	UIImage *savedImage = [UIImage imageWithData:imageData];
	Texture2D *savedImageTexture = [[Texture2D alloc] initWithImage:savedImage];
	
	[savedImageTexture drawInRect:self.bounds srcEnum:GL_ONE dstEnum:GL_ZERO];
	[savedImageTexture release];
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderbuffer);
	[_context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void) createSavedPreviewImageData:(NSData*)imageData {
	UIImage *savedImage = [UIImage imageWithData:imageData];
	
	_previousDrawnImage.image = savedImage;
	_previousDrawnImage.hidden = NO;
}

- (void) createClearPreviewImageData {
	NSString *paperFileName;
//	if (_iPhoneDevice) {
//		paperFileName = [NSString stringWithFormat:@"%@.png", kImage_Paper];
//	} else {
		paperFileName = [NSString stringWithFormat:@"%@_iPad.png", kImage_Paper];
//	}
	UIImage *image = [UIImage imageNamed:paperFileName];
	
	_previousDrawnImage.image = image;
	_previousDrawnImage.hidden = NO;
}

#pragma mark -
#pragma mark Image Saving

- (void)saveToPhotoLibrary {
	GLubyte *buffer = (GLubyte *) malloc(_viewHeight*_viewWidth*4);
	glReadPixels(0,0,_viewWidth,_viewHeight,GL_RGBA,GL_UNSIGNED_BYTE,buffer);
	CGDataProviderRef ref = CGDataProviderCreateWithData(buffer, buffer, _viewHeight*_viewWidth*4, releaseDataCallback);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGImageRef iref = CGImageCreate(_viewWidth,_viewHeight,8,32,_viewWidth*4,colorSpace,kCGBitmapByteOrderDefault,ref,NULL,true,kCGRenderingIntentDefault);
	
	size_t width         = CGImageGetWidth(iref);
	size_t height        = CGImageGetHeight(iref);
	size_t length        = width*height*4;
	uint32_t *pixels     = (uint32_t *)malloc(length);
	CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width*4, CGImageGetColorSpace(iref), kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrderDefault);
	
	CGContextTranslateCTM(context, 0.0, height);
	
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), iref);
	
	CGImageRef outputRef = CGBitmapContextCreateImage(context);
	UIImage *drawingImage = [UIImage imageWithCGImage:outputRef];
	
	CGDataProviderRelease(ref);
	CGColorSpaceRelease(colorSpace);
	CGImageRelease(iref);
	CGImageRelease(outputRef);
	CGContextRelease(context);
	
	UIGraphicsBeginImageContext(drawingImage.size);  
    // Draw drawing
    [drawingImage drawInRect:CGRectMake(0, 0, drawingImage.size.width, drawingImage.size.height)];  
	// Draw paper image  
    [_paperView.image drawInRect:CGRectMake(0, 0, _image.image.size.width, _image.image.size.height)]; 
    // Draw outline image  
    [_image.image drawInRect:CGRectMake(0, 0, _image.image.size.width, _image.image.size.height)];  
  
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();  
 
    UIGraphicsEndImageContext(); 
	
	UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), pixels);
} 

- (void)imageSavedToPhotosAlbum:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
	if (!error) {
		NSLog(@"SUCCESSFUL SAVE");
	} else {
		NSLog(@"ERROR SAVE");
	}  
	free(contextInfo);
	contextInfo = nil;
} 

// callback for CGDataProviderCreateWithData
void releaseDataCallback (void *info, const void *data, size_t size) {
	//free((void*)data); // free the
	NSLog(@"freeing data");
//	free(&data);
//	data = nil;
	free(info);
	info = nil;
	NSLog(@"data freed");
}

#pragma mark -
#pragma mark Get/Set _imageFileName

- (void) set_imageFileName:(NSString*)newImageFileName {
	NSString *imageFileName;
	
	if (_imageFileName) {
		[_imageFileName release];
	}
	
	_imageFileName = [[NSString alloc] initWithString:newImageFileName];
	
	if ([newImageFileName length] == 0) {
		_image.hidden = YES;
	} else {
//		if (_iPhoneDevice) {
//			imageFileName = [NSString stringWithFormat:@"%@.png", newImageFileName];
//		} else {
			imageFileName = [NSString stringWithFormat:@"%@_iPad.png", newImageFileName];
//		}
		
		_image.image = [UIImage imageNamed:imageFileName];
		_image.hidden = NO;
	}
	
}
- (NSString*) _imageFileName {
	return _imageFileName;
}

@end