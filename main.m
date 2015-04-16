//
//  main.m
//  FingerPaintAnimals
//
//  Created by Orange Design on 3/24/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//
//
//#import <UIKit/UIKit.h>
//
//int main(int argc, char *argv[]) {
//    
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    //int retVal = UIApplicationMain(argc, argv, nil, nil);
//    
//    [pool release];
//    int retVal = UIApplicationMain(argc, argv, nil, @"FingerPaintAnimalsAppDelegate");
//    return retVal;
//}

#import <UIKit/UIKit.h>
#import "FingerPaintAnimalsAppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([FingerPaintAnimalsAppDelegate class]));
    }
}
