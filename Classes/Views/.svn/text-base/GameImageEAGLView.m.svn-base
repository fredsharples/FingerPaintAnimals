#import "GameImageEAGLView.h"

@implementation GameImageEAGLView

@synthesize _showSpeckles;

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self != nil) {
		[self initializeView];
	}
	return self;
}

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
	if ((self = [super initWithCoder:coder])) {
		[self initializeView];
	}
	
	return self;
}

- (void) initializeView {
	NSString *speckleFileName, *paperFileName;
	
	self.backgroundColor = [UIColor whiteColor];
	
//	_iPhoneDevice = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad;
	
	//Set up OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	glOrthof(0, self.bounds.size.width, 0, self.bounds.size.height, -1, 1);
	glMatrixMode(GL_MODELVIEW);
	
	glEnable(GL_TEXTURE_2D);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	
	_firstDraw = YES;
	_showSpeckles = YES;
	_imageFileName = [[NSString alloc] initWithString:@""];
	
//	if (_iPhoneDevice) {
//		speckleFileName = [NSString stringWithFormat:@"%@.png", kImage_Speckle];
//		paperFileName = [NSString stringWithFormat:@"%@.png", kImage_Paper];
//	} else {
		speckleFileName = [NSString stringWithFormat:@"%@_iPad.png", kImage_Speckle];
		paperFileName = [NSString stringWithFormat:@"%@_iPad.png", kImage_Paper];
//	}
	_speckle =  [[Texture2D alloc] initWithImage: [UIImage imageNamed:speckleFileName]];
	_paper = [[Texture2D alloc] initWithImage: [UIImage imageNamed:paperFileName]];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void) drawView {
	_firstDraw = NO;

	glDisable(GL_BLEND);
	[_image drawInRect:self.bounds];
	
	glEnable(GL_BLEND);
	if (_showSpeckles) {
		[_speckle drawInRect:self.bounds srcEnum:GL_ONE dstEnum:GL_ONE_MINUS_SRC_COLOR];
	}
	
	[_paper drawInRect:self.bounds srcEnum:GL_DST_COLOR dstEnum:GL_ZERO];

	[self swapBuffers];
}

- (void)dealloc {
	[_image release];
	[_speckle release];
	[_paper release];
	
	[_imageFileName release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Get/Set _imageFileName

- (void) set_imageFileName:(NSString*)newImageFileName {
	NSString *imagePath;
	
	if (_firstDraw || [newImageFileName localizedCompare:_imageFileName] != NSOrderedSame) {
		if (!_firstDraw) {
			[_image release];
			[_imageFileName release];
		}
		
		_imageFileName = [[NSString alloc] initWithString:newImageFileName];
		
//		if (_iPhoneDevice) {
//			imagePath = [NSString stringWithFormat:@"%@.png", _imageFileName];
//		} else {
			imagePath = [NSString stringWithFormat:@"%@_iPad.png", _imageFileName];
//		}
		
		_image = [[Texture2D alloc] initWithImage: [UIImage imageNamed:imagePath]];
		
		[self drawView];
	}
}
- (NSString*) _imageFileName {
	return _imageFileName;
}

@end