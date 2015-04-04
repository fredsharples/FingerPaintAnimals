#import <UIKit/UIKit.h>

@interface GameButton : UIButton {
	float _r;
	float _g;
	float _b;
	
	NSString *_vo;
}

@property float _r;
@property float _g;
@property float _b;
@property (nonatomic, retain) NSString *_vo;

@end
