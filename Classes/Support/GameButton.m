#import "GameButton.h"

@implementation GameButton

@synthesize _r, _g, _b, _vo;

- (void)dealloc {
	[_vo release];
	
    [super dealloc];
}

@end
