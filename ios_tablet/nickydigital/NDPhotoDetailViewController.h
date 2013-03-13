//
//  NDPhotoDetailControllerViewController.h
//  nickydigital
//
//  Created by Terrence Curran on 2/23/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDPhotoDetailModalPanel.h"
#import "PopoverView.h"
#import "Photo.h"

@interface NDPhotoDetailViewController : UIViewController<UIWebViewDelegate, UITextViewDelegate, PopoverViewDelegate> {
}


@property (nonatomic, retain) IBOutlet UIImageView *photoView;

@property (nonatomic, retain) NDPhotoDetailModalPanel *detailPanel;

- (void)setPhoto:(Photo*)photo withView:(UIImageView*)imageView;

- (IBAction)btnFacebookShareClick:(id)sender;
- (IBAction)btnTwitterShareClick:(id)sender;
- (IBAction)btnTumblrShareClick:(id)sender;
- (IBAction)btnEmailShareClick:(id)sender;
- (IBAction)btnTumblrBlogChooseClick:(id)sender;

- (IBAction)btnEmailClick:(id)sender;

- (IBAction)btnShareClick:(id)sender;

- (void)updateShareButtons;

@end
