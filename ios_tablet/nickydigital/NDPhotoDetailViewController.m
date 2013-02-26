//
//  NDPhotoDetailControllerViewController.m
//  nickydigital
//
//  Created by Terrence Curran on 2/23/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "NDPhotoDetailViewController.h"
#import "NDConstants.h"
#import "NDMainViewController.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"

@interface NDPhotoDetailViewController () {
	IBOutlet UIView	*viewLoadedFromXib;
	IBOutlet UIView	*emailView;
	IBOutlet UITextField *emailField;
}
@end

@implementation NDPhotoDetailViewController

@synthesize photoView;

NSString *userEmailAddress;
NSString *userFacebookToken;
NSString *userFacebookUser;


- (void)loadView
{
	//if (theFrame.size.width == NULL) {
	//	theFrame = [[UIScreen mainScreen] applicationFrame];
	//}

	[[NSBundle mainBundle] loadNibNamed:@"PhotoDetail" owner:self options:nil];
	[[NSBundle mainBundle] loadNibNamed:@"EmailView" owner:self options:nil];

	//viewLoadedFromXib.frame = view.contentView.frame;
	
	NDPhotoDetailModalPanel *view = [[NDPhotoDetailModalPanel alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] content:viewLoadedFromXib]; //theFrame];
	view.contentColor = [UIColor whiteColor];
	view.shouldBounce = NO;
	
	// add subviews
	self.detailPanel = view;
	self.view = view;
}

-(void)setPhoto:(UIImageView*)imageView {
	self.photoView.image = imageView.image;
	
}

//- (void)layoutSubviews {
//	[super layoutSubviews];
//
//	[v setFrame:self.contentView.bounds];
//}

-(void)showFacebookShareConfirm {
	RIButtonItem *cancelItem = [RIButtonItem item];
	cancelItem.label = @"No";
	cancelItem.action = ^
	{
		// this is the code that will be executed when the user taps "No"
		// this is optional... if you leave the action as nil, it won't do anything
		// but here, I'm showing a block just to show that you can use one if you want to.
	};
	
	RIButtonItem *deleteItem = [RIButtonItem item];
	deleteItem.label = @"Yes";
	deleteItem.action = ^
	{
		// this is the code that will be executed when the user taps "Yes"
		// delete the object in question...
		//[context deleteObject:theObject];
	};
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Share on Facebook?"
														message:@"Are you sure you want to share this photo on facebook?"
											   cancelButtonItem:cancelItem
											   otherButtonItems:deleteItem, nil];
	[alertView show];
	
}

- (IBAction)btnFacebookShareClick:(id)sender {

    UIViewController *modalDialog = [[UIViewController alloc] init];
    modalDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    modalDialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

	[self presentAutoModalViewController:modalDialog animated:YES];

	modalDialog.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    [modalDialog.view addSubview:emailView];
    
    modalDialog.view.superview.center = centerOfView;
	
	
	nextAction = ACTION_FACEBOOK;
	
	//	[self presentAutoModalView:emailView withDismissAction:nil withNextAction:ACTION_FACEBOOK animated:YES];

	//[self facebookLogin];

}
    
- (void)facebookLogin {
	
	nextAction = 0;
	
    NSString *facebookOauthUrl = [NSString stringWithFormat:kFacebookOauth, kFacebookAppId, kFacebookRedirect, @"state123", kFacebookScope];
	
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIViewController *modalDialog = [[UIViewController alloc] init];
    modalDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    modalDialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	//
	//    UIWebView *webView = [[UIWebView alloc] init];
	//    NSString *fullURL = @"http://www.google.com"; NSURL *url = [NSURL URLWithString:fullURL]; NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	//    [webView loadRequest:requestObj];
	//
	//
    
	//    UINavigationController *navController = [[UINavigationController alloc]
	//                     initWithRootViewController:modalDialog];
	//
	//    [self presentViewController:navController animated:YES completion:^{
	//        // nothing;
	//    }];
    
	
	[self presentAutoModalViewController:modalDialog animated:YES];
	
    //[self presentViewController:modalDialog animated:YES completion:^{
	// nothing
    //}];
    
    //[V1 presentModalViewController:V2 animated:YES];
    modalDialog.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    UIWebView *webView =[[UIWebView alloc] initWithFrame:CGRectMake(0,0,600,400)];
    //    webView.delegate = self;
	
    NSURL *url = [NSURL URLWithString:facebookOauthUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView setDelegate:self];
    [webView loadRequest:requestObj];
    [modalDialog.view addSubview:webView];
    
    modalDialog.view.superview.center = centerOfView;
	
	
	//    [V2.view addSubview:webView];
	
	
	//    CGRect frame = CGRectMake(0,0,200,200);
	//    UIWebView *vw2 =[[UIWebView alloc] initWithFrame:frame];
	////    webView.delegate = self;
	//        NSString *fullURL = @"http://www.google.com"; NSURL *url = [NSURL URLWithString:fullURL]; NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	//        [vw2 loadRequest:requestObj];
	//
	//    [self.view addSubview:vw2];
    
    
    //[V1 release];
}

int nextAction;
const int ACTION_FACEBOOK = 1;

- (IBAction)btnEmailClick:(id)sender
{
	userEmailAddress = emailField.text;
	[self autoModalViewControllerDismiss:sender];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];
    
	
    NSInteger nickyDigitalInUrl = [url rangeOfString:kFacebookRedirect].location;
    if (nickyDigitalInUrl != NSNotFound && nickyDigitalInUrl == 0) {
		
        NSArray *authUrlComponents = [url componentsSeparatedByString:@"&"];
		
        NSString *oauthToken;
        for (NSString *authUrlComponent in authUrlComponents) {
            NSLog(@"url %@", authUrlComponent);
            NSInteger authTokenParameterPosition = [authUrlComponent rangeOfString:@"access_token="].location;
            NSLog(@"position %d", authTokenParameterPosition);
            if (authTokenParameterPosition != NSNotFound && authTokenParameterPosition == 0) {
                oauthToken = [authUrlComponent substringFromIndex:@"access_token=".length];
            }
        }
        
		
		[self autoModalViewControllerDismiss:nil];
		[self showFacebookShareConfirm];
		
		NDMainViewController *mainView = [NDMainViewController singleton];
		[mainView displayLoggedIn];
		
//        [[[UIAlertView alloc]
//          initWithTitle:@"OAuth Token"
//          message: oauthToken
//          delegate:self
//          cancelButtonTitle:@"Ok"
//          otherButtonTitles: nil] show];
        
        return false;
    }
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // NSString *url = [[[webView request] URL] absoluteString];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

	NSLog(@"allHTML: %@", html);

	[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.forms[0].email.value='%@';", userEmailAddress]];

	//NSLog(@"result: %@", result);
	//	[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('L$lbsc$txtUserName').value='ANdrew';"];
}

- (void) presentAutoModalView: (UIView *) modalView withDismissAction:(SEL)onDismiss withNextAction:(int)nextActionVal animated:(BOOL)animated
{
	nextAction = nextActionVal;
    
	UINavigationController* nc = [[UINavigationController alloc] init];
	//[nc.view addSubview:modalView];
	nc.view = modalView;
		
	[nc setToolbarHidden:YES animated: NO];
	
	//UIViewController* rootViewController = [nc.viewControllers objectAtIndex: 0];
	nc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																										target:self
																										action:onDismiss];

    
	[nc setNavigationBarHidden: NO];
    nc.navigationBar.barStyle = UIBarStyleBlack;
    nc.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
	
	[self presentViewController:nc animated:animated completion:^{
        // nothing
    }];
	
	
	nc.view.superview.frame = CGRectMake(0, 0, 600, 440); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
	
	nc.view.superview.center = centerOfView;

}

- (void) presentAutoModalViewController: (UIViewController *) modalViewController withDismissAction: (SEL) onDismiss animated:(BOOL)animated
{
    UINavigationController* nc = nil;
    if ( NO == [ modalViewController isKindOfClass: [UINavigationController class]] )
    {
        nc = [[UINavigationController alloc] initWithRootViewController: modalViewController];
		
        [nc setToolbarHidden:YES animated: NO];
		
        nc.modalPresentationStyle = modalViewController.modalPresentationStyle;
		
        modalViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																											 target:self
																											 action:onDismiss];
    }
    else
    {
        nc = (UINavigationController*) modalViewController;
		
        UIViewController* rootViewController = [nc.viewControllers objectAtIndex: 0];
        rootViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																											target:self
																											action:onDismiss];
    }
	
    [nc setNavigationBarHidden: NO];
    nc.navigationBar.barStyle = UIBarStyleBlack;
    nc.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
	
	[self presentViewController:nc animated:animated completion:^{
        // nothing
    }];
	
	
	nc.view.superview.frame = CGRectMake(0, 0, 600, 440); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
	
	nc.view.superview.center = centerOfView;
	
}

- (void) presentAutoModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
    [self presentAutoModalViewController:modalViewController withDismissAction: @selector(autoModalViewControllerDismiss:) animated: animated];
}

- (void) autoModalViewControllerDismiss: (id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{

		switch (nextAction) {
			case ACTION_FACEBOOK:
				[self facebookLogin];
				break;
				
			default:
				break;
		}
	
	}];
}

- (BOOL) isAutoModalViewController
{
    return ( self.navigationController != nil && self.navigationController.parentViewController != nil && self.navigationController.parentViewController.modalViewController == self.navigationController );
}


@end
