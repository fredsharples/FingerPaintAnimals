//
//  LegalViewController.h
//  MadrigalChallenge
//
//  Created by Susan Surapruik on 7/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameImageViewController.h"

@interface LegalViewController : GameImageViewController {
	UIButton *_moreGamesButton;
	UIImageView *_noWebConnection;
}

- (BOOL) connectedToNetwork:(NSString*)urlString;

@end