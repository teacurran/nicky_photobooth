//
//  NDRoot.h
//  nickydigital
//
//  Created by Terrence Curran on 2/17/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIGlossyButton.h"

@interface NDMainViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *serviceLoginView;
@property (nonatomic, retain) IBOutlet UILabel *labelLoggedOut;
@property (nonatomic, retain) IBOutlet UILabel *labelAccountMessage;
@property (nonatomic, retain) IBOutlet UIGlossyButton *buttonLogOut;

- (IBAction)btnLogoutClick:(id)sender;

+ (id)singleton;

-(UIColor*)brandColor;
-(bool)loggedIn;
-(void)logInWithMessage:(NSString*)message;

@end
