//
//  GameWindow.m
//  ColoringBookAnimals
//
//  Created by Susan Surapruik on 10/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameWindow.h"


@implementation GameWindow

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (motion == UIEventSubtypeMotionShake ) {
		// User was shaking the device. Post a notification named "shake".
		[[NSNotificationCenter defaultCenter] postNotificationName:@"shakeStart" object:self];
	}
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (motion == UIEventSubtypeMotionShake ) {
		// User was shaking the device. Post a notification named "shake".
		[[NSNotificationCenter defaultCenter] postNotificationName:@"shakeEnd" object:self];
	}
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {	
	if (motion == UIEventSubtypeMotionShake ) {
		// User was shaking the device. Post a notification named "shake".
		[[NSNotificationCenter defaultCenter] postNotificationName:@"shakeEnd" object:self];
	}
}

@end
