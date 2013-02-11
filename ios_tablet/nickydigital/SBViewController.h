//
//  SBViewController.h
//  smilebooth
//
//  Created by Terrence Curran on 1/10/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBViewController : UIViewController<UIWebViewDelegate>

- (IBAction)btnFacebookShareClick:(id)sender;

- (void)webViewDidFinishLoad:(UIWebView *)webView;

@end
