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

#import "NDConstants.h"
#import "NDApiClient.h"
#import "NDPhotoDetailViewController.h"
#import "NDConstants.h"
#import "NDMainViewController.h"

#import "OAuth.h"
#import "OAuthConsumerCredentials.h"

@interface NDPhotoDetailViewController () {
    IBOutlet UIView *photoDetailView;
    IBOutlet UIButton *photoDetailFacebookButton;
    IBOutlet UIButton *photoDetailTwitterButton;
    IBOutlet UIButton *photoDetailTumblrButton;
    IBOutlet UIButton *photoDetailEmailButton;

    IBOutlet UIView *emailView;
    IBOutlet UITextField *emailField;
    IBOutlet UIGlossyButton *emailButton;

    IBOutlet UIView *shareView;
    IBOutlet UIImageView *shareImageView;
    IBOutlet UIGlossyButton *shareButton;
    IBOutlet UITextView *shareTextView;

    IBOutlet UIView *emailShareView;
    IBOutlet UIImageView *emailShareImageView;
    IBOutlet UITextField *emailShareFromField;
    IBOutlet UITextField *emailShareToField;
    IBOutlet UITextView *emailShareBodyView;
    IBOutlet UIGlossyButton *emailShareButton;

}
@end

@implementation NDPhotoDetailViewController

@synthesize photoView;

const int ACTION_NONE = 0;
const int ACTION_FACEBOOK_EMAIL = 1;
const int ACTION_FACEBOOK_LOGIN = 2;
const int ACTION_FACEBOOK_SHARE = 3;
const int ACTION_TWITTER_EMAIL = 4;
const int ACTION_TWITTER_LOGIN = 5;
const int ACTION_TWITTER_SHARE = 6;
const int ACTION_EMAIL_SHARE = 7;

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

OAuth *twitterOAuth;

CGRect originalPhotoViewFrame;

NDMainViewController *mainViewController = nil;


- (void)loadView {
    //if (theFrame.size.width == NULL) {
    //	theFrame = [[UIScreen mainScreen] applicationFrame];
    //}

    mainViewController = [NDMainViewController singleton];

	// Photo Detail View
    [[NSBundle mainBundle] loadNibNamed:@"PhotoDetailView" owner:self options:nil];

    // Email View
    [[NSBundle mainBundle] loadNibNamed:@"EmailView" owner:self options:nil];
    emailButton.borderColor = mainViewController.brandColor;
    emailButton.tintColor = mainViewController.brandColor;
    [emailButton useWhiteLabel:YES];
    [emailButton setShadow:[UIColor blackColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius:4];
    [emailButton setGradientType:kUIGlossyButtonGradientTypeLinearSmoothStandard];
    //[emailButton setGradientType:kUIGlossyButtonGradientTypeLinearSmoothExtreme];
    //[emailButton setExtraShadingType:kUIGlossyButtonExtraShadingTypeAngleRight];
	[emailField setKeyboardType:UIKeyboardTypeEmailAddress];

    // Share View
    [[NSBundle mainBundle] loadNibNamed:@"ShareView" owner:self options:nil];
    shareButton.borderColor = mainViewController.brandColor;
    shareButton.tintColor = mainViewController.brandColor;
    [shareButton useWhiteLabel:YES];
    [shareButton setShadow:[UIColor blackColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius:4];
    [shareButton setGradientType:kUIGlossyButtonGradientTypeLinearSmoothStandard];

    shareTextView.layer.cornerRadius = 8.0f;
    shareTextView.layer.masksToBounds = YES;
    shareTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    shareTextView.layer.borderWidth = 1.0f;

    // Email Share View
    [[NSBundle mainBundle] loadNibNamed:@"EmailShareView" owner:self options:nil];
    emailShareBodyView.layer.cornerRadius = 8.0f;
    emailShareBodyView.layer.masksToBounds = YES;
    emailShareBodyView.layer.borderColor = [[UIColor grayColor] CGColor];
    emailShareBodyView.layer.borderWidth = 1.0f;

	emailShareButton.borderColor = mainViewController.brandColor;
    emailShareButton.tintColor = mainViewController.brandColor;
    [emailShareButton useWhiteLabel:YES];
    [emailShareButton setShadow:[UIColor blackColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius:4];
    [emailShareButton setGradientType:kUIGlossyButtonGradientTypeLinearSmoothStandard];

    
	//viewLoadedFromXib.frame = view.contentView.frame;

    NDPhotoDetailModalPanel *view = [[NDPhotoDetailModalPanel alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] content:photoDetailView]; //theFrame];
    view.contentColor = [UIColor whiteColor];
    view.shouldBounce = NO;

    // add subviews
    self.detailPanel = view;
    self.view = view;

    if (mainViewController.event.showFacebook) {
        photoDetailFacebookButton.hidden = false;
    } else {
        [photoDetailFacebookButton setHidden:YES];
    }

    if (mainViewController.event.showTwitter) {
        photoDetailTwitterButton.hidden = false;
    } else {
        [photoDetailTwitterButton setHidden:YES];
    }

    if (mainViewController.event.showTumblr) {
        photoDetailTumblrButton.hidden = false;
    } else {
        [photoDetailTumblrButton setHidden:YES];
    }

    if (mainViewController.event.showEmail) {
        photoDetailEmailButton.hidden = false;
    } else {
        [photoDetailEmailButton setHidden:YES];
    }
	
	[photoView.layer setBorderColor: [[UIColor blackColor] CGColor]];
	[photoView.layer setBorderWidth: 1.0];

}

- (void)setPhoto:(Photo *)photo withView:(UIImageView *)imageView {
    _photo = photo;
    self.photoView.image = imageView.image;
	
	if (imageView.image != nil) {
		if (originalPhotoViewFrame.size.width == 0) {
			originalPhotoViewFrame = self.photoView.frame;
		}

		self.photoView.frame = originalPhotoViewFrame;
		
		CGRect frame = [self getFrameSizeForImage:imageView.image  inImageView:self.photoView];

		CGRect imageViewFrame = CGRectMake(self.photoView.frame.origin.x + frame.origin.x, self.photoView.frame.origin.y + frame.origin.y, frame.size.width, frame.size.height);
		self.photoView.frame = imageViewFrame;
	}
}

- (void)updateShareButtons {

    Event *event = mainViewController.event;

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

- (void)showFacebookShareConfirm {
    RIButtonItem *cancelItem = [RIButtonItem item];
    cancelItem.label = @"No";
    cancelItem.action = ^{
        // this is the code that will be executed when the user taps "No"
        // this is optional... if you leave the action as nil, it won't do anything
        // but here, I'm showing a block just to show that you can use one if you want to.
    };

    RIButtonItem *deleteItem = [RIButtonItem item];
    deleteItem.label = @"Yes";
    deleteItem.action = ^{
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

    if (mainViewController.loggedIn && facebookLoggedIn) {
        [self facebookShare];
        return;
    } else if (!mainViewController.loggedIn) {
		[self logout];
    } else {
		[self facebookLogin];
		return;
	}

    currentAction = ACTION_FACEBOOK_EMAIL;
    nextAction = ACTION_FACEBOOK_LOGIN;

    UIViewController *modalDialog = [[UIViewController alloc] init];
    modalDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    modalDialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self autoModalViewControllerPresent:modalDialog animated:YES];

    modalDialog.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

    [modalDialog.view addSubview:emailView];

    modalDialog.view.superview.center = centerOfView;

}

- (IBAction)btnTwitterShareClick:(id)sender {

    if (mainViewController.loggedIn && twitterLoggedIn) {
        [self twitterShare];
        return;
    } else if (!mainViewController.loggedIn) {
		[self logout];
	} else {
		[self twitterLogin];
		return;
    }

    currentAction = ACTION_TWITTER_EMAIL;
    nextAction = ACTION_TWITTER_LOGIN;

    UIViewController *modalDialog = [[UIViewController alloc] init];
    modalDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    modalDialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self autoModalViewControllerPresent:modalDialog animated:YES];

    modalDialog.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

    [modalDialog.view addSubview:emailView];

    modalDialog.view.superview.center = centerOfView;

}

- (IBAction)btnTumblrShareClick:(id)sender {


}

- (IBAction)btnEmailShareClick:(id)sender {

    currentAction = ACTION_EMAIL_SHARE;
    nextAction = nil;
	
    UIViewController *modalDialog = [[UIViewController alloc] init];
    modalDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    modalDialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
    [self autoModalViewControllerPresent:modalDialog animated:YES];
	
    modalDialog.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
	
    emailShareImageView.image = photoView.image;
	emailShareFromField.text = userEmailAddress;
	emailShareToField.text = nil;
	emailShareBodyView.text = [[NDMainViewController singleton] event].emailShare;
    
	[modalDialog.view addSubview:emailShareView];
	
    modalDialog.view.superview.center = centerOfView;
	
}


- (void)facebookShare {
    currentAction = ACTION_FACEBOOK_SHARE;

    UIViewController *modalDialog = [[UIViewController alloc] init];
    modalDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    modalDialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self autoModalViewControllerPresent:modalDialog animated:YES];

    modalDialog.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

    shareImageView.image = photoView.image;

    shareTextView.text = [[NDMainViewController singleton] event].longShare;
	[shareTextView setDelegate:nil];

    [modalDialog.view addSubview:shareView];

    modalDialog.view.superview.center = centerOfView;

}


- (void)facebookLogin {
    currentAction = ACTION_FACEBOOK_LOGIN;
    nextAction = ACTION_FACEBOOK_SHARE;

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

    [self autoModalViewControllerPresent:modalDialog animated:YES];

    modalDialog.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 600, 400)];

    NSURL *url = [NSURL URLWithString:facebookOauthUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView setDelegate:self];
    [webView loadRequest:requestObj];
    [modalDialog.view addSubview:webView];

    modalDialog.view.superview.center = centerOfView;
}

- (void)twitterShare {
    currentAction = ACTION_TWITTER_SHARE;

    UIViewController *modalDialog = [[UIViewController alloc] init];
    modalDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    modalDialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self autoModalViewControllerPresent:modalDialog animated:YES];

    modalDialog.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

    shareImageView.image = photoView.image;

    shareTextView.text = [[NDMainViewController singleton] event].shortShare;
	[shareTextView setDelegate:self];

    [modalDialog.view addSubview:shareView];

    modalDialog.view.superview.center = centerOfView;

}

- (void)twitterLogin {
    currentAction = ACTION_TWITTER_LOGIN;
    nextAction = ACTION_TWITTER_SHARE;

	twitterOAuth = [[OAuth alloc] initWithConsumerKey:kTwitterConsumerKey andConsumerSecret:kTwitterConsumerSecret];
	[twitterOAuth synchronousRequestTwitterTokenWithCallbackUrl:@"http://www.nickydigital.com"];

	
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

    UIViewController *modalDialog = [[UIViewController alloc] init];
    modalDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    modalDialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self autoModalViewControllerPresent:modalDialog animated:YES];

    modalDialog.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 600, 400)];

	NSDictionary * params = [NSDictionary dictionaryWithObject:twitterOAuth.oauth_token forKey:@"oauth_token"];

    NSURL *url = [self generateURL:@"http://api.twitter.com/oauth/authorize" params:params];

    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView setDelegate:self];
    [webView loadRequest:requestObj];
    [modalDialog.view addSubview:webView];

    modalDialog.view.superview.center = centerOfView;
}

- (IBAction)btnShareClick:(id)sender {

    nextAction = ACTION_NONE;

	NSRegularExpression *emailRegex = [NSRegularExpression regularExpressionWithPattern:kEmailRegex options:NSRegularExpressionCaseInsensitive error:nil];
	
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
                                                       nil]
        ];

        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        }                                                                                   failure:nil];

        [operation start];

        [self autoModalViewControllerDismissWithNext:nil];

    }

    if (currentAction == ACTION_TWITTER_SHARE) {
        NDApiClient *client = [NDApiClient sharedClient];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
		
        NSURLRequest *request = [client requestWithMethod:@"POST"
                                                     path:@"/api/twittershare"
                                               parameters:[NSDictionary dictionaryWithObjectsAndKeys:
														   emailField.text, @"email",
														   twitterOAuth.oauth_token, @"token",
														   twitterOAuth.oauth_token_secret, @"tokensecret",
														   _photo.filename, @"filename",
														   shareTextView.text, @"body",
														   nil]
								 ];
		
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
			
        }                                                                                   failure:nil];
		
        [operation start];
		
        [self autoModalViewControllerDismissWithNext:nil];
		
    }
	
	if (currentAction == ACTION_EMAIL_SHARE) {
		NSString *emailFrom = (emailShareFromField.text == nil) ? @"" : emailShareFromField.text;
		NSString *emailTo = (emailShareToField.text == nil) ? @"" : emailShareToField.text;

		NSTextCheckingResult *validateFromAddress = [emailRegex firstMatchInString:emailFrom options:0 range:NSMakeRange(0, [emailFrom length])];
		NSTextCheckingResult *validateToAddress = [emailRegex firstMatchInString:emailTo options:0 range:NSMakeRange(0, [emailTo length])];

		if (!validateFromAddress && !validateToAddress) {
			UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
															  message:@"Please enter a valid from and to email address"
															 delegate:nil
													cancelButtonTitle:@"OK"
													otherButtonTitles:nil];
			[message show];
			return;
		} else if (!validateFromAddress) {
			UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
															  message:@"Please enter a valid from email address"
															 delegate:nil
													cancelButtonTitle:@"OK"
													otherButtonTitles:nil];
			[message show];
			return;
		} else if (!validateToAddress) {
			UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
															  message:@"Please enter a valid to email address"
															 delegate:nil
													cancelButtonTitle:@"OK"
													otherButtonTitles:nil];
			[message show];
			return;
		}

		NDApiClient *client = [NDApiClient sharedClient];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
		
        NSURLRequest *request = [client requestWithMethod:@"POST"
                                                     path:@"/api/emailshare"
                                               parameters:[NSDictionary dictionaryWithObjectsAndKeys:
														   emailFrom, @"email_from",
														   emailTo, @"email_to",
														   emailShareBodyView.text, @"email_body",
														   _photo.filename, @"filename",
														   nil]
								 ];
		
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
			
        }                                                                                   failure:nil];
		
        [operation start];
		
        [self autoModalViewControllerDismissWithNext:nil];
	}


}

- (IBAction)btnEmailClick:(id)sender {
    userEmailAddress = emailField.text;
	emailField.text = @"";

    NDApiClient *client = [NDApiClient sharedClient];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];

    NSURLRequest *request = [client requestWithMethod:@"POST"
                                                 path:@"/api/emailcapture"
                                           parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   emailField.text, @"email", nil]
    ];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {


    }                                                                                   failure:nil];

    [operation start];


    [self autoModalViewControllerDismissWithNext:sender];
}

/**
* Web View Methods
*/
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = request.URL;
	NSString *host = [url host];
    NSString *urlString = [[request URL] absoluteString];

	if (currentAction == ACTION_FACEBOOK_LOGIN) {
		NSInteger nickyDigitalInUrl = [urlString rangeOfString:kFacebookRedirect].location;
		if (nickyDigitalInUrl != NSNotFound && nickyDigitalInUrl == 0) {

			NSArray *authUrlComponents = [urlString componentsSeparatedByString:@"&"];

			for (NSString *authUrlComponent in authUrlComponents) {
				NSLog(@"url %@", authUrlComponent);
				NSInteger authTokenParameterPosition = [authUrlComponent rangeOfString:@"access_token="].location;
				NSLog(@"position %d", authTokenParameterPosition);
				if (authTokenParameterPosition != NSNotFound && authTokenParameterPosition == 0) {
					userFacebookToken = [authUrlComponent substringFromIndex:@"access_token=".length];

					nextAction = ACTION_FACEBOOK_SHARE;

					loggedIn = YES;
					facebookLoggedIn = YES;
					[mainViewController logInFacebook];
				}
			}

			[self autoModalViewControllerDismissWithNext:nil];

			return false;
		}
	}
	
	if (currentAction == ACTION_TWITTER_LOGIN) {
		NSLog(@"%@", host);
		NSLog(@"%@", [url absoluteString]);
		if ([host isEqualToString:@"www.nickydigital.com"]) {
			NSLog(@"At Yatterbox");
			if ([[url.resourceSpecifier substringToIndex:8] isEqualToString:@"//cancel"] ||
				[url.resourceSpecifier rangeOfString:@"?denied="].location != NSNotFound) {
				[self autoModalViewControllerDismiss:nil];
			} else {
				NSLog(@"Suceeded Now Getting Access Token");

				[twitterOAuth synchronousAuthorizeTwitterTokenWithVerifier:[self getStringFromUrl:[url absoluteString] needle:@"oauth_verifier="]];

				nextAction = ACTION_TWITTER_SHARE;
				
				loggedIn = YES;
				twitterLoggedIn = YES;
				[mainViewController logInTwitter];

				[self autoModalViewControllerDismissWithNext:nil];
			}
			return NO;
		}
	}
	
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	CGRect frame = webView.frame;
	NSLog(@"frame:%f", frame.origin.y);

    // NSString *url = [[[webView request] URL] absoluteString];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	CGRect frame = webView.frame;
	NSLog(@"frame:%f", frame.origin.y);

	//NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
	//NSLog(@"allHTML: %@", html);

    if (currentAction == ACTION_FACEBOOK_LOGIN) {
        //NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        //NSLog(@"allHTML: %@", html);

        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.forms[0].email.value='%@';", userEmailAddress]];

        //NSLog(@"result: %@", result);
        //	[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('L$lbsc$txtUserName').value='ANdrew';"];
    }

	if (currentAction == ACTION_TWITTER_LOGIN) {
		
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.forms[0].username_or_email.value='%@';", userEmailAddress]];
		
	}

}

- (void)logout {
	userEmailAddress = nil;
	twitterOAuth = nil;
	loggedIn = NO;
	facebookLoggedIn = NO;
	twitterLoggedIn = NO;
	tumblrLoggedIn = NO;
}


- (void)autoModalViewControllerPresent:(UIViewController *)modalViewController withDismissAction:(SEL)onDismiss animated:(BOOL)animated {
    UINavigationController *nc = nil;
    if (NO == [modalViewController isKindOfClass:[UINavigationController class]]) {
        nc = [[UINavigationController alloc] initWithRootViewController:modalViewController];

        [nc setToolbarHidden:YES animated:NO];

        nc.modalPresentationStyle = modalViewController.modalPresentationStyle;

        modalViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                                             target:self
                                                                                                             action:onDismiss];
    }
    else {
        nc = (UINavigationController *) modalViewController;

        UIViewController *rootViewController = [nc.viewControllers objectAtIndex:0];
        rootViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                                            target:self
                                                                                                            action:onDismiss];
    }

    [nc setNavigationBarHidden:NO];
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

- (void)autoModalViewControllerPresent:(UIViewController *)modalViewController animated:(BOOL)animated {
    [self autoModalViewControllerPresent:modalViewController withDismissAction:@selector(autoModalViewControllerDismiss:) animated:animated];
}

- (void)autoModalViewControllerDismissWithNext:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{

        switch (nextAction) {
            case ACTION_FACEBOOK_LOGIN:
                [self facebookLogin];
                break;

            case ACTION_FACEBOOK_SHARE:
                [self facebookShare];
                break;

            case ACTION_TWITTER_LOGIN:
                [self twitterLogin];
                break;
				
            case ACTION_TWITTER_SHARE:
                [self twitterShare];
                break;

            default:
                break;
        }

    }];
}

- (void)autoModalViewControllerDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (BOOL)isAutoModalViewController {
    return (self.navigationController != nil && self.navigationController.parentViewController != nil && self.navigationController.parentViewController.modalViewController == self.navigationController);
}

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
    if (params) {
        NSMutableArray* pairs = [NSMutableArray array];
        for (NSString* key in params.keyEnumerator) {
            NSString* value = [params objectForKey:key];
            NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
																						  NULL, /* allocator */
																						  (CFStringRef)value,
																						  NULL, /* charactersToLeaveUnescaped */
																						  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																						  kCFStringEncodingUTF8));
            
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        }
        
        NSString* query = [pairs componentsJoinedByString:@"&"];
        NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
        return [NSURL URLWithString:url];
    } else {
        return [NSURL URLWithString:baseURL];
    }
}

- (CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView {
	
    float hfactor = image.size.width / imageView.frame.size.width;
    float vfactor = image.size.height / imageView.frame.size.height;
	
    float factor = fmax(hfactor, vfactor);
	
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
	
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = (imageView.frame.size.width - newWidth) / 2;
    float topOffset = (imageView.frame.size.height - newHeight) / 2;
	
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}

/**
 * Find a specific parameter from the url
 */
- (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle {
    NSString * str = nil;
    NSRange start = [url rangeOfString:needle];
    if (start.location != NSNotFound) {
        NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
        NSUInteger offset = start.location+start.length;
        str = end.location == NSNotFound
        ? [url substringFromIndex:offset]
        : [url substringWithRange:NSMakeRange(offset, end.location)];
        str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return str;
}


- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length >= 120)
    {
    	textView.text = [textView.text substringToIndex:120];
    }
}

@end
