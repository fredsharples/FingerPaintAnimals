#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "Constants.h"

void releaseDataCallback (
   void *info,
   const void *data,
   size_t size
);

//CLASS INTERFACE:
@interface DrawEAGLView : UIView {
	EAGLContext *_context;
	GLuint _framebuffer;
	GLuint _renderbuffer;
	GLuint _depthBuffer;
	
	UIImageView *_image;
	
	// used to save a copy of the drawing during flip transitions
	UIImageView *_previousDrawnImage;
	
	Texture2D *_paper;
	Texture2D *_brush;
	
	BOOL _clearFirst;
	BOOL _firstDraw;
	NSString *_imageFileName;
	
	// ADDED FOR ERASER /////////////////////////////////////////////////
	UIImageView *_paperView;
	/////////////////////////////////////////////////////////////////////
	
	BOOL _iPhoneDevice;
	int _viewWidth;
	int _viewHeight;
}

- (instancetype)initWithCoder:(NSCoder*)coder NS_DESIGNATED_INITIALIZER; 

- (void) initializeView;
- (void) changeLineColorR:(float)r G:(float)g B:(float)b;
- (void) clearDrawnPoints;
- (void) drawFromPoint:(CGPoint)start toPoint:(CGPoint)end;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData *convertImageToData;
- (void) drawSavedImageData:(NSData*)imageData;
- (void) createSavedPreviewImageData:(NSData*)imageData;
- (void) createClearPreviewImageData;

- (void) saveToPhotoLibrary;
- (void) imageSavedToPhotosAlbum:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo;

@property (nonatomic, retain) NSString *_imageFileName;
@property (nonatomic, retain) UIImageView *_previousDrawnImage;
@property (nonatomic, retain) UIImageView *_paperView;

@end
