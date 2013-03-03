//
//  NDPhotoDetailControllerViewController.m
//  nickydigital
//
//  Created by Terrence Curran on 2/23/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "AFNetworkActivityIndicatorManager.h"
#import "AFJSONRequestOperation.h"
#import "UIAlertView+Blocks.h"
#import "UIGlossyButton.h"
#import "UIView+LayerEffects.h"
#import "RIButtonItem.h"

#import "NDApiClient.h"
#import "NDPhotoDetailViewController.h"
#import "NDConstants.h"
#import "NDMainViewController.h"

@interface NDPhotoDetailViewController () {
	IBOutlet UIView	*photoDetailView;
	IBOutlet UIButton *photoDetailFacebookButton;
	IBOutlet UIButton *photoDetailTwitterButton;
	IBOutlet UIButton *photoDetailTumblrButton;
	IBOutlet UIButton *photoDetailEmailButton;

	IBOutlet UIView	*emailView;
	IBOutlet UITextField *emailField;
	IBOutlet UIGlossyButton *emailButton;

	IBOutlet UIView *shareView;
	IBOutlet UIImageView *shareImageView;
	IBOutlet UIGlossyButton *shareButton;
	IBOutlet UITextView *shareTextView;
}
@end

@implementation NDPhotoDetailViewController

@synthesize photoView;

const int ACTION_NONE = 0;
const int ACTION_FACEBOOK_EMAIL = 1;
const int ACTION_FACEBOOK_LOGIN = 2;
const int ACTION_FACEBOOK_SHARE = 3;

int currentAction = ACTION_NONE;
int nextAction = ACTION_NONE;

Photo *_photo = nil;

bool loggedIn = false;
bool facebookLoggedIn = false;
bool twitterLoggedIn = false;
bool tumblrLoggedIn = false;

NSString *userEmailAddress;
NSString *userFacebookToken;
NSString *userFacebookUser;

NDMainViewController *_mainViewController = nil;


- (void)loadView
{
	//if (theFrame.size.width == NULL) {
	//	theFrame = [[UIScreen mainScreen] applicationFrame];
	//}

	[[NSBundle mainBundle] loadNibNamed:@"PhotoDetailView" owner:self options:nil];

	
	// Email View
	[[NSBundle mainBundle] loadNibNamed:@"EmailView" owner:self options:nil];
	emailButton.borderColor = [[self mainViewController] brandColor];
	emailButton.tintColor = [[self mainViewController] brandColor];
	[emailButton useWhiteLabel: YES];
	[emailButton setShadow:[UIColor blackColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
	[emailButton setGradientType:kUIGlossyButtonGradientTypeLinearSmoothStandard];
	//[emailButton setGradientType:kUIGlossyButtonGradientTypeLinearSmoothExtreme];
	//[emailButton setExtraShadingType:kUIGlossyButtonExtraShadingTypeAngleRight];
	
	// Share View
	[[NSBundle mainBundle] loadNibNamed:@"ShareView" owner:self options:nil];
	shareButton.borderColor = [[self mainViewController] brandColor];
	shareButton.tintColor = [[self mainViewController] brandColor];
	[shareButton useWhiteLabel: YES];
	[shareButton setShadow:[UIColor blackColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
	[shareButton setGradientType:kUIGlossyButtonGradientTypeLinearSmoothStandard];
	
	shareTextView.layer.cornerRadius=8.0f;
    shareTextView.layer.masksToBounds=YES;
    shareTextView.layer.borderColor=[[UIColor grayColor]CGColor];
    shareTextView.layer.borderWidth= 1.0f;

	//viewLoadedFromXib.frame = view.contentView.frame;
	
	NDPhotoDetailModalPanel *view = [[NDPhotoDetailModalPanel alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] content:photoDetailView]; //theFrame];
	view.contentColor = [UIColor whiteColor];
	view.shouldBounce = NO;
	
	// add subviews
	self.detailPanel = view;
	self.view = view;

	if ([[self mainViewController] event].showFacebook) {
		photoDetailFacebookButton.hidden = false;
	} else {
		[photoDetailFacebookButton setHidden:YES];
	}
	
	if ([[self mainViewController] event].showTwitter) {
		photoDetailTwitterButton.hidden = false;
	} else {
		[photoDetailTwitterButton setHidden:YES];
	}
	
	if ([[self mainViewController] event].showTumblr) {
		photoDetailTumblrButton.hidden = false;
	} else {
		[photoDetailTumblrButton setHidden:YES];
	}
	
	if ([[self mainViewController] event].showEmail) {
		photoDetailEmailButton.hidden = false;
	} else {
		[photoDetailEmailButton setHidden:YES];
	}

}

-(void)setPhoto:(Photo*)photo withView:(UIImageView*)imageView {
	_photo = photo;
	self.photoView.image = imageView.image;
	
}

- (void)updateShareButtons {
	
	Event *event = [[self mainViewController] event];
	
	int x_first = 0; // x value of first button
	int x_space = 140; // distance between button x values
	
	int buttons_visible = 0;
	
	if (event.showFacebook) {
		[photoDetailFacebookButton setFrame:CGRectMake(
											x_first + (buttons_visible * x_space),
											photoDetailFacebookButton.frame.origin.y,
											photoDetailFacebookButton.frame.size.width,
											photoDetailFacebookButton.frame.size.height
													   )];
		
		[photoDetailFacebookButton setHidden:NO];

		buttons_visible++;
	} else {
		[photoDetailFacebookButton setHidden:YES];
	}
	
	if (event.showTwitter) {
		[photoDetailTwitterButton setFrame:CGRectMake(
													   x_first + (buttons_visible * x_space),
													   photoDetailTwitterButton.frame.origin.y,
													   photoDetailTwitterButton.frame.size.width,
													   photoDetailTwitterButton.frame.size.height
													   )];

		
		[photoDetailTwitterButton setHidden:NO];
		buttons_visible++;
	} else {
		[photoDetailTwitterButton setHidden:YES];
	}
	
	if (event.showTumblr) {
		[photoDetailTumblrButton setFrame:CGRectMake(
													  x_first + (buttons_visible * x_space),
													  photoDetailTumblrButton.frame.origin.y,
													  photoDetailTumblrButton.frame.size.width,
													  photoDetailTumblrButton.frame.size.height
													  )];

		[photoDetailTumblrButton setHidden:NO];
		buttons_visible++;
	} else {
		[photoDetailTumblrButton setHidden:YES];
	}
	
	if (event.showEmail) {
		[photoDetailEmailButton setFrame:CGRectMake(
													 x_first + (buttons_visible * x_space),
													 photoDetailEmailButton.frame.origin.y,
													 photoDetailEmailButton.frame.size.width,
													 photoDetailEmailButton.frame.size.height
													 )];

		[photoDetailEmailButton setHidden:NO];
		buttons_visible++;
	} else {
		[photoDetailEmailButton setHidden:YES];
	}
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

	if ([[self mainViewController] loggedIn] && facebookLoggedIn) {
		[self facebookShare];
		return;
	}

	currentAction = ACTION_FACEBOOK_EMAIL;
	nextAction = ACTION_FACEBOOK_LOGIN;

    UIViewController *modalDialog = [[UIViewController alloc] init];
    modalDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    modalDialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

	[self presentAutoModalViewController:modalDialog animated:YES];

	modalDialog.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    [modalDialog.view addSubview:emailView];
    
    modalDialog.view.superview.center = centerOfView;
	
}

- (IBAction)btnShareClick:(id)sender {
	
	if (currentAction == ACTION_FACEBOOK_SHARE) {
		NDApiClient *client = [NDApiClient sharedClient];
		[[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
		[[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
		
		NSURLRequest *request = [client requestWithMethod:@"POST"
													 path:@"/api/facebookshare"
											   parameters:[NSDictionary dictionaryWithObjectsAndKeys:
														   emailField.text, @"email",
														   userFacebookToken, @"token",
														   _photo.filename, @"filename",
														   shareTextView.text, @"body",
														   nil
														   ]
								 ];
		
		AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
			
			
		} failure:nil];
		
		[operation start];
		
		
	}
	
}


- (void)facebookShare {
	currentAction = ACTION_FACEBOOK_SHARE;
	
    UIViewController *modalDialog = [[UIViewController alloc] init];
    modalDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    modalDialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
	[self presentAutoModalViewController:modalDialog animated:YES];
	
	modalDialog.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
	shareImageView.image = photoView.image;
	
	shareTextView.text = [[NDMainViewController singleton] event].longShare;
	
    [modalDialog.view addSubview:shareView];
    
    modalDialog.view.superview.center = centerOfView;
	
}
    
- (void)facebookLogin {
	
	currentAction = ACTION_FACEBOOK_LOGIN;
	nextAction = ACTION_FACEBOOK_SHARE;

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

- (IBAction)btnEmailClick:(id)sender
{
	userEmailAddress = emailField.text;
	
	NDApiClient *client = [NDApiClient sharedClient];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
	
    NSURLRequest *request = [client requestWithMethod:@"POST"
												path:@"/api/emailcapture"
												parameters:[NSDictionary dictionaryWithObjectsAndKeys:
																			emailField.text, @"email", nil
															]
							 ];
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		
		
	} failure:nil];
	
	[operation start];
	
	
	[self autoModalViewControllerDismissWithNext:sender];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];
    
	
    NSInteger nickyDigitalInUrl = [url rangeOfString:kFacebookRedirect].location;
    if (nickyDigitalInUrl != NSNotFound && nickyDigitalInUrl == 0) {
		
        NSArray *authUrlComponents = [url componentsSeparatedByString:@"&"];
		
        for (NSString *authUrlComponent in authUrlComponents) {
            NSLog(@"url %@", authUrlComponent);
            NSInteger authTokenParameterPosition = [authUrlComponent rangeOfString:@"access_token="].location;
            NSLog(@"position %d", authTokenParameterPosition);
            if (authTokenParameterPosition != NSNotFound && authTokenParameterPosition == 0) {
                userFacebookToken = [authUrlComponent substringFromIndex:@"access_token=".length];

				nextAction = ACTION_FACEBOOK_SHARE;
				
				[[self mainViewController] logInFacebook];
            }
        }
		
		[self autoModalViewControllerDismissWithNext:nil];
		
        return false;
    }
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // NSString *url = [[[webView request] URL] absoluteString];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	if (currentAction == ACTION_FACEBOOK_LOGIN) {
		//NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
		//NSLog(@"allHTML: %@", html);

		[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.forms[0].email.value='%@';", userEmailAddress]];

		//NSLog(@"result: %@", result);
		//	[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('L$lbsc$txtUserName').value='ANdrew';"];
	}
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

- (void) autoModalViewControllerDismissWithNext: (id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
		
		switch (nextAction) {
			case ACTION_FACEBOOK_LOGIN:
				[self facebookLogin];
				break;
				
			case ACTION_FACEBOOK_SHARE:
				[self facebookShare];
				break;
				
			default:
				break;
		}
		
	}];
}

- (void) autoModalViewControllerDismiss: (id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{

	}];
}

- (BOOL) isAutoModalViewController
{
    return ( self.navigationController != nil && self.navigationController.parentViewController != nil && self.navigationController.parentViewController.modalViewController == self.navigationController );
}

- (NDMainViewController*) mainViewController
{
	if (!_mainViewController) {
		_mainViewController = [NDMainViewController singleton];
	}
	return _mainViewController;
}
	 
@end
