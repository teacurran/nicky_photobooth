//
//  NDPhotoDetailControllerViewController.h
//  nickydigital
//
//  Created by Terrence Curran on 2/23/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDPhotoDetailModalPanel.h"

@interface NDPhotoDetailViewController : UIViewController<UIWebViewDelegate> {
}


@property (nonatomic, retain) IBOutlet UIImageView *photoView;

@property (nonatomic, retain) NDPhotoDetailModalPanel *detailPanel;

- (void)setPhoto:(UIImageView*)imageView;

- (IBAction)btnFacebookShareClick:(id)sender;

- (IBAction)btnEmailClick:(id)sender;

- (void)facebookLogin;


@end
