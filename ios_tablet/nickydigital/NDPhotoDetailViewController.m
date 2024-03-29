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
#import "PopoverView.h"
#import "M13Checkbox.h"

#import "NDConstants.h"
#import "NDApiClient.h"
#import "NDPhotoDetailViewController.h"
#import "NDConstants.h"
#import "NDMainViewController.h"
#import "NDTumblrUser.h"
#import "NDTumblrBlog.h"

#import "OAuth.h"
#import "OAuthConsumerCredentials.h"
#import "NDSyncHTTPRequest.h"

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
	
    IBOutlet UIView *tumblrShareView;
    IBOutlet UIImageView *tumblrShareImageView;
    IBOutlet UIButton *tumblrShareBlogName;
    IBOutlet UITextView *tumblrShareBodyView;
    IBOutlet UIGlossyButton *tumblrShareButton;

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
const int ACTION_EMAIL_EMAIL = 7;
const int ACTION_EMAIL_SHARE = 8;
const int ACTION_TUMBLR_EMAIL = 9;
const int ACTION_TUMBLR_LOGIN = 10;
const int ACTION_TUMBLR_SHARE = 11;

int currentAction = ACTION_NONE;
int nextAction = ACTION_NONE;

Photo *_photo = nil;

bool loggedIn = false;
bool facebookLoggedIn = false;
bool twitterLoggedIn = false;
bool tumblrLoggedIn = false;

// used to reset the photoview back to it's default size after changing to accomidate an image
CGRect originalPhotoViewFrame;

NDMainViewController *mainViewController = nil;

NSString *userEmailAddress;

// twitter related
OAuth *twitterOAuth;
UILabel *twitterRemainingLabel;
UILabel *twitterRemainingDescLabel;
int maxTextCharacters = 120;
bool twitterCountVisible = NO;

// tumblr related
OAuth *tumblrOAuth;
NDTumblrUser *tumblrUser;
int tumblrSelectedBlog = 0;
PopoverView *tumblrChoosePopover;

// facebook related
NSString *userFacebookToken;
NSString *userFacebookUser;
M13Checkbox *facebookLikeCheckbox;
bool facebookLikeVisible = NO;
int facebookLikeOffset = 0;	// an offset of how much we moved the share text box to fit the facebook like button

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

	// Facebook
	facebookLikeCheckbox = [[M13Checkbox alloc] initWithTitle:@"Like Nicky Digital on Facebook?" andHeight:20];
	
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

    // Tumblr Share View
    [[NSBundle mainBundle] loadNibNamed:@"TumblrShareView" owner:self options:nil];
    tumblrShareBodyView.layer.cornerRadius = 8.0f;
    tumblrShareBodyView.layer.masksToBounds = YES;
    tumblrShareBodyView.layer.borderColor = [[UIColor grayColor] CGColor];
    tumblrShareBodyView.layer.borderWidth = 1.0f;
	
	tumblrShareButton.borderColor = mainViewController.brandColor;
    tumblrShareButton.tintColor = mainViewController.brandColor;
    [tumblrShareButton useWhiteLabel:YES];
    [tumblrShareButton setShadow:[UIColor blackColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius:4];
    [tumblrShareButton setGradientType:kUIGlossyButtonGradientTypeLinearSmoothStandard];

	// Twitter Controls
	twitterRemainingLabel = [[UILabel alloc] init];
	twitterRemainingLabel.text = [NSString stringWithFormat:@"%d", maxTextCharacters];
	twitterRemainingDescLabel = [[UILabel alloc] init];
	twitterRemainingDescLabel.text = @"remaining";
	
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

- (void)logout {
	userEmailAddress = nil;
	twitterOAuth = nil;
	tumblrUser = nil;
	tumblrOAuth = nil;
	loggedIn = NO;
	facebookLoggedIn = NO;
	twitterLoggedIn = NO;
	tumblrLoggedIn = NO;
}


# pragma mark - Email

- (IBAction)btnEmailShareClick:(id)sender {
    
	if (mainViewController.loggedIn) {
        [self emailShare];
        return;
    } else {
		[self logout];
    }
    
    currentAction = ACTION_EMAIL_EMAIL;
    nextAction = ACTION_EMAIL_SHARE;
	
    UIViewController *modalDialog = [[UIViewController alloc] init];
    modalDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    modalDialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
    [self autoModalViewControllerPresent:modalDialog animated:YES];
    
    modalDialog.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
	
    [modalDialog.view addSubview:emailView];
	emailView.frame = modalDialog.view.frame;
	
    modalDialog.view.superview.center = centerOfView;
	
}

- (IBAction)emailShare {
    
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
	emailShareToField.text = userEmailAddress;
	emailShareBodyView.text = [[NDMainViewController singleton] event].emailShare;
    
    if (!mainViewController.loggedIn) {
		userEmailAddress = nil;
    }
    
	[modalDialog.view addSubview:emailShareView];
    
	emailShareView.frame = CGRectMake(modalDialog.view.frame.origin.x,
                                      modalDialog.view.frame.origin.y + 40,
                                      modalDialog.view.frame.size.width,
                                      modalDialog.view.frame.size.height);
	
    modalDialog.view.superview.center = centerOfView;
	
}


# pragma mark - Tumblr

- (IBAction)btnTumblrShareClick:(id)sender {
    if (mainViewController.loggedIn && tumblrLoggedIn) {
        [self tumblrShare];
        return;
    } else if (!mainViewController.loggedIn) {
		[self logout];
	} else {
		// we are logged in with something, so skip the email signup
		[self tumblrLogin];
		return;
    }
	
    currentAction = ACTION_TUMBLR_EMAIL;
    nextAction = ACTION_TUMBLR_LOGIN;
	
    UIViewController *modalDialog = [[UIViewController alloc] init];
    modalDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    modalDialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
    [self autoModalViewControllerPresent:modalDialog animated:YES];
	
    //modalDialog.view.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    //CGRect bounds = self.view.bounds;
    //CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
	
    [modalDialog.view addSubview:emailView];
	emailView.frame = modalDialog.view.frame;
	
    //modalDialog.view.center = centerOfView;


}



- (void)tumblrShare {
    currentAction = ACTION_TUMBLR_SHARE;
	
    UIViewController *modalDialog = [[UIViewController alloc] init];
    modalDialog.modalPresentationStyle = UIModalPresentationFormSheet;
    modalDialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
    [self autoModalViewControllerPresent:modalDialog animated:YES];
	
    modalDialog.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
	
    tumblrShareImageView.image = photoView.image;
	
    tumblrShareBodyView.text = [[NDMainViewController singleton] event].tumblrShare;
	
    [modalDialog.view addSubview:tumblrShareView];

	tumblrShareView.frame = CGRectMake(modalDialog.view.frame.origin.x,
                                      modalDialog.view.frame.origin.y + 40,
                                      modalDialog.view.frame.size.width,
                                      modalDialog.view.frame.size.height);

	
    modalDialog.view.superview.center = centerOfView;
	
}

- (IBAction)btnTumblrBlogChooseClick:(id)sender {

	UIButton *button = (UIButton*)sender;
	
	CGRect frameInWindow = [button convertRect:button.bounds toView:self.view];
	
	CGPoint point = CGPointMake(
				frameInWindow.origin.x + (button.frame.size.width / 2),
				frameInWindow.origin.y);
	
	NSMutableArray *blogTitles = [[NSMutableArray alloc] init];
	
	for (NDTumblrBlog *blog in tumblrUser.blogs) {
		[blogTitles addObject:blog.title];
	}
	
	tumblrChoosePopover = [PopoverView showPopoverAtPoint:point
                                  inView:self.view
                               withTitle:@"Choose a blog to post to"
                         withStringArray:blogTitles
                                delegate:self];
	
}



- (void)tumblrLogin {
    currentAction = ACTION_TUMBLR_LOGIN;
    nextAction = ACTION_TUMBLR_SHARE;
	
	Event *event = [[NDMainViewController singleton] event];
	tumblrOAuth = [[OAuth alloc] initWithConsumerKey:event.tumblrConsumerKey andConsumerSecret:event.tumblrConsumerSecret];

	// Invalidate the previous request token, whether it was authorized or not.
	[tumblrOAuth setOauth_token_authorized:NO]; // We are invalidating whatever token we had before.
	[tumblrOAuth setOauth_token:@""];
	[tumblrOAuth setOauth_token_secret:@""];
	
	// Calculate the header.
    
    // Guard against someone forgetting to set the callback. Pretend that we have out-of-band request
    // in that case.
    NSDictionary *requestTokenParams = [NSDictionary dictionaryWithObject:kTumblrCallBackUrl forKey:@"oauth_callback"];
	NSString *oauth_header = [tumblrOAuth oAuthHeaderForMethod:@"POST" andUrl:kTumblrRequestTokenUrl andParams:requestTokenParams];
	
	// Synchronously perform the HTTP request.
	NDSyncHTTPRequest *request = [NDSyncHTTPRequest requestWithURL:[NSURL URLWithString:kTumblrRequestTokenUrl]];
	request.requestMethod = @"POST";
	[request addRequestHeader:@"Authorization" value:oauth_header];
	[request startSynchronous];
	
	NSArray *responseBodyComponents = [[request responseString] componentsSeparatedByString:@"&"];
	// For a successful response, break the response down into pieces and set the properties
	// with KVC. If there's a response for which there is no local property or ivar, this
	// may end up with setValue:forUndefinedKey:.
	for (NSString *component in responseBodyComponents) {
		NSArray *subComponents = [component componentsSeparatedByString:@"="];
		[tumblrOAuth setValue:[subComponents objectAtIndex:1] forKey:[subComponents objectAtIndex:0]];
	}
	
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
	
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 600, 440)];
	
	NSDictionary * params = [NSDictionary dictionaryWithObject:tumblrOAuth.oauth_token forKey:@"oauth_token"];
	
    NSURL *url = [self generateURL:kTumblrAuthorizeUrl params:params];
	
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

		NSString *likeOnFacebook = @"false";
		if (facebookLikeCheckbox.state == M13CheckboxStateChecked) {
			likeOnFacebook = @"true";
		}
		
		NSString *emailAddress = (emailField.text == nil) ? @"" : emailField.text;
		NSDictionary *requestParams = [NSDictionary dictionaryWithObjectsAndKeys:
								emailAddress, @"email",
								userFacebookToken, @"token",
								_photo.filename, @"filename",
								likeOnFacebook, @"like",
								shareTextView.text, @"body",
								nil];
		
        NSURLRequest *request = [client requestWithMethod:@"POST"
                                                     path:@"/api/facebookshare"
                                               parameters: requestParams
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

	if (currentAction == ACTION_TUMBLR_SHARE) {
		NDTumblrBlog *selectedBlog = [tumblrUser.blogs objectAtIndex:tumblrSelectedBlog];

		NDApiClient *client = [NDApiClient sharedClient];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];

        NSURLRequest *request = [client requestWithMethod:@"POST"
                                                     path:@"/api/tumblrshare"
                                               parameters:[NSDictionary dictionaryWithObjectsAndKeys:
														   tumblrOAuth.oauth_token, @"token",
														   tumblrOAuth.oauth_token_secret, @"tokensecret",
														   _photo.filename, @"filename",
														   selectedBlog.hostname, @"hostname",
														   tumblrUser.name, @"username",
														   tumblrShareBodyView.text, @"body",
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

	emailField.text = @"";
    [self autoModalViewControllerDismissWithNext:sender];
}

# pragma mark - Facebook

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
	[self hideTwitterCharCount];
	
	
	if ([[NDMainViewController singleton] event].showFacebookLike) {
		[self showFacebookShareCheckbox];
	} else {
		[self hideFacebookShareCheckbox];
	}
	
    [modalDialog.view addSubview:shareView];
    
    shareView.frame = CGRectMake(modalDialog.view.frame.origin.x,
                                       modalDialog.view.frame.origin.y + 40,
                                       modalDialog.view.frame.size.width,
                                       modalDialog.view.frame.size.height);

	
    modalDialog.view.superview.center = centerOfView;
	
}


- (void)facebookLogin {
    currentAction = ACTION_FACEBOOK_LOGIN;
    nextAction = ACTION_FACEBOOK_SHARE;
	
	Event *event = [[NDMainViewController singleton] event];
    NSString *facebookOauthUrl = [NSString stringWithFormat:kFacebookOauth, event.facebookConsumerKey, kFacebookRedirect, @"state123", kFacebookScope];
	
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
	
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 600, 440)];
	
    NSURL *url = [NSURL URLWithString:facebookOauthUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView setDelegate:self];
    [webView loadRequest:requestObj];
    [modalDialog.view addSubview:webView];
	
    modalDialog.view.superview.center = centerOfView;
}

- (void)showFacebookShareCheckbox {
	[facebookLikeCheckbox setState:M13CheckboxStateChecked];
	
	NSString *facebookLikeText = [[NDMainViewController singleton] event].facebookLikeText;
	
	if ([facebookLikeText length] == 0) {
		facebookLikeText = @"Like Nicky Digital on Facebook?";
	}
	
	[facebookLikeCheckbox setTitle:facebookLikeText];
	
	if (facebookLikeVisible) {
		return;
	}
	
    facebookLikeCheckbox.frame = CGRectMake(shareTextView.frame.origin.x,
											shareTextView.frame.origin.y + shareTextView.frame.size.height + 10,
											facebookLikeCheckbox.frame.size.width,
											facebookLikeCheckbox.frame.size.height);
	
    [shareView addSubview:facebookLikeCheckbox];
	
	facebookLikeVisible = YES;
	
}

- (void)hideFacebookShareCheckbox {
	if (!facebookLikeVisible) {
		return;
	}
	
	[facebookLikeCheckbox removeFromSuperview];
	
	facebookLikeVisible = NO;
}




- (IBAction)btnFacebookShareClick:(id)sender {
	
    if (mainViewController.loggedIn && facebookLoggedIn) {
        [self facebookShare];
        return;
    } else if (!mainViewController.loggedIn) {
		[self logout];
    } else {
		// we are logged in with something, so skip the email signup
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

    emailView.frame = CGRectMake(modalDialog.view.frame.origin.x,
                                 modalDialog.view.frame.origin.y + 40,
                                 modalDialog.view.frame.size.width,
                                 modalDialog.view.frame.size.height);
	
    modalDialog.view.superview.center = centerOfView;
	
}

# pragma mark - Twitter

- (IBAction)btnTwitterShareClick:(id)sender {
	
    if (mainViewController.loggedIn && twitterLoggedIn) {
        [self twitterShare];
        return;
    } else if (!mainViewController.loggedIn) {
		[self logout];
	} else {
		// we are logged in with something, so skip the email signup
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
	emailView.frame = modalDialog.view.frame;
	
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
	
	// set the delegate to limit the text entry length
	[shareTextView setDelegate:self];
	[self showTwitterCharCount];
	
	
    [modalDialog.view addSubview:shareView];
	shareView.frame = modalDialog.view.frame;
	
    modalDialog.view.superview.center = centerOfView;
	
}

- (void)twitterLogin {
    currentAction = ACTION_TWITTER_LOGIN;
    nextAction = ACTION_TWITTER_SHARE;

	Event *event = [[NDMainViewController singleton] event];
	twitterOAuth = [[OAuth alloc] initWithConsumerKey:event.twitterConsumerKey andConsumerSecret:event.twitterConsumerSecret];
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
	
    NSURL *url = [self generateURL:@"https://api.twitter.com/oauth/authorize" params:params];
	
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView setDelegate:self];
    [webView loadRequest:requestObj];
    [modalDialog.view addSubview:webView];
	
    modalDialog.view.superview.center = centerOfView;
}

- (void)showTwitterCharCount {
	if (twitterCountVisible) {
		return;
	}

    twitterRemainingLabel.frame = CGRectMake(shareTextView.frame.origin.x,
											shareTextView.frame.origin.y + shareTextView.frame.size.height + 10,
											facebookLikeCheckbox.frame.size.width,
											facebookLikeCheckbox.frame.size.height);
	
    [shareView addSubview:twitterRemainingLabel];
	
	// trigger the text view did change to update the count
	[self textViewDidChange:shareTextView];
	
	twitterCountVisible = YES;
	

}

- (void)hideTwitterCharCount {
	if (!twitterCountVisible) {
		return;
	}
	
	[twitterRemainingLabel removeFromSuperview];
	
	twitterCountVisible = NO;
}


# pragma mark - WebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = request.URL;
	NSString *host = [url host];
    NSString *urlString = [[request URL] absoluteString];
	NSLog(@"Webview loaded url:%@", urlString);

	if (currentAction == ACTION_FACEBOOK_LOGIN) {
		NSInteger nickyDigitalInUrl = [urlString rangeOfString:kFacebookRedirect].location;
		if (nickyDigitalInUrl != NSNotFound && nickyDigitalInUrl == 0) {

			NSString *urlStringFixed = [urlString stringByReplacingOccurrencesOfString:@"#" withString:@"&"];

			NSArray *authUrlComponents = [urlStringFixed componentsSeparatedByString:@"&"];

			for (NSString *authUrlComponent in authUrlComponents) {
				NSLog(@"url %@", authUrlComponent);
				NSInteger authTokenParameterPosition = [authUrlComponent rangeOfString:@"access_token="].location;
				NSLog(@"position %d", authTokenParameterPosition);
				if (authTokenParameterPosition != NSNotFound && authTokenParameterPosition == 0) {
					userFacebookToken = [authUrlComponent substringFromIndex:@"access_token=".length];

					NSLog(@"facebook access token %@", userFacebookToken);
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
	
	if (currentAction == ACTION_TUMBLR_LOGIN) {
		NSLog(@"%@", host);
		NSLog(@"%@", [url absoluteString]);
		if ([host isEqualToString:@"www.nickydigital.com"]) {

			// denied: http://www.nickydigital.com/oauth/tumblr#_=_
			// auth: http://www.nickydigital.com/oauth/tumblr?oauth_token=SjrDdj7HMbvzSnE0yVpElq98uxQqyNZ8wS2MGoxuDEiCLhUFYh&oauth_verifier=O3TGwMUyFZeLkftdfeBFFerN9MpKHo5outOxkkf32mhAFiQIJN#_=_
			
			if ([urlString isEqualToString:@"http://www.nickydigital.com/oauth/tumblr#_=_"]) {
				[self autoModalViewControllerDismiss:nil];
			} else {
				
				NSLog(@"Suceeded Now Getting Access Token");
				
				NSString *tokenVerifier = [self getStringFromUrl:urlString needle:@"oauth_verifier="];
				
				// We manually specify the token as a param, because it has not yet been authorized
				// and the automatic state checking wouldn't include it in signature construction or header,
				// since oauth_token_authorized is still NO by this point.
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
										[tumblrOAuth oauth_token], @"oauth_token",
										tokenVerifier, @"oauth_verifier",
										nil];
				
				NSString *oauth_header = [tumblrOAuth oAuthHeaderForMethod:@"POST" andUrl:kTumblrAccessTokenUrl andParams:params andTokenSecret:[tumblrOAuth oauth_token_secret]];

				NDSyncHTTPRequest *syncTumblrAccessTokenRequest = [NDSyncHTTPRequest requestWithURL:[NSURL URLWithString:kTumblrAccessTokenUrl]];
				syncTumblrAccessTokenRequest.requestMethod = @"POST";
				[syncTumblrAccessTokenRequest addRequestHeader:@"Authorization" value:oauth_header];
				[syncTumblrAccessTokenRequest startSynchronous];
				
				if ([syncTumblrAccessTokenRequest error]) {
					
					NSLog(@"HTTP return code for token authorization error: %d, message: %@, string: %@", syncTumblrAccessTokenRequest.responseStatusCode, syncTumblrAccessTokenRequest.responseStatusMessage, syncTumblrAccessTokenRequest.responseString);
					NSLog(@"OAuth header was: %@", oauth_header);
					
				} else {
					NSArray *responseBodyComponents = [[syncTumblrAccessTokenRequest responseString] componentsSeparatedByString:@"&"];
					for (NSString *component in responseBodyComponents) {
						// Tumblr returns oauth_token, oauth_token_secret.
						NSArray *subComponents = [component componentsSeparatedByString:@"="];
						[tumblrOAuth setValue:[subComponents objectAtIndex:1] forKey:[subComponents objectAtIndex:0]];
					}
					
					[tumblrOAuth setOauth_token_authorized:YES];


					NSDictionary *userInfoParams = [[NSDictionary alloc] init];
					NSString *userInfoOauthHeader = [tumblrOAuth oAuthHeaderForMethod:@"GET" andUrl:kTumblrUserInfo andParams:userInfoParams];
					NDSyncHTTPRequest *syncUserInfoRequest = [NDSyncHTTPRequest requestWithURL:[NSURL URLWithString:kTumblrUserInfo]];
					syncUserInfoRequest.requestMethod = @"GET";
					[syncUserInfoRequest addRequestHeader:@"Authorization" value:userInfoOauthHeader];
					[syncUserInfoRequest startSynchronous];
					
					if ([syncUserInfoRequest error]) {
						
						NSLog(@"HTTP return code for token authorization error: %d, message: %@, string: %@", syncUserInfoRequest.responseStatusCode, syncUserInfoRequest.responseStatusMessage, syncUserInfoRequest.responseString);
						NSLog(@"OAuth header was: %@", oauth_header);
						
					} else {
						NSError *error = nil;

						NSData *JSONData = [[syncUserInfoRequest responseString] dataUsingEncoding:NSUTF8StringEncoding];
						NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:JSONData options:nil error:&error];

						NSDictionary *responseDict = [JSON objectForKey:@"response"];
						NSDictionary *responseUser = [responseDict objectForKey:@"user"];

						tumblrUser = [[NDTumblrUser alloc] init];
						tumblrUser.name = [responseUser objectForKey:@"name"];

						id responseBlogs = [responseUser objectForKey:@"blogs"];
						for (id jsonBlog in responseBlogs) {
							NDTumblrBlog *blog = [[NDTumblrBlog alloc] init];
							blog.name = [jsonBlog objectForKey:@"name"];
							blog.url = [jsonBlog objectForKey:@"url"];
							blog.title = [jsonBlog objectForKey:@"title"];
							
							[tumblrUser.blogs addObject:blog];
						}

						
						if (tumblrUser.blogs.count == 0) {
							NDTumblrBlog *blog = [[NDTumblrBlog alloc] init];
							blog.title = @"default";
							[tumblrUser.blogs addObject:blog];
						}
						
						[self selectTumblrBlog:0];
						
						nextAction = ACTION_TUMBLR_SHARE;
						
						loggedIn = YES;
						tumblrLoggedIn = YES;
						[mainViewController logInTumblr];
						
					}

					
					
					[self autoModalViewControllerDismissWithNext:nil];

				
				}
				
				return NO;
			}
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

	if (currentAction == ACTION_TUMBLR_LOGIN) {
		
        [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('signup_button_cancel').style.visibility='hidden';"];
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.forms[0]['user[email]'].value='%@';", userEmailAddress]];
		
	}
}


# pragma mark - popoverViewDelegate
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index {
    
	[self selectTumblrBlog:index];
	
    // Dismiss the PopoverView after 0.5 seconds
    [popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.1f];
}

- (void)selectTumblrBlog:(int)index {
	
	tumblrSelectedBlog = index;
	NSString *blogTitle = ((NDTumblrBlog*)[tumblrUser.blogs objectAtIndex:index]).title;
	CGSize stringsize = [blogTitle sizeWithFont:[UIFont systemFontOfSize:17]];
	
	[tumblrShareBlogName setFrame:CGRectMake(tumblrShareBlogName.frame.origin.x,
											 tumblrShareBlogName.frame.origin.y,
											 stringsize.width + 10,
											 tumblrShareBlogName.frame.size.height)];
	
	[tumblrShareBlogName setTitle:blogTitle forState:UIControlStateNormal];

}

# pragma mark - autoModalViewController
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


    nc.view.superview.frame = CGRectMake(0, 0, 600, 400); //it's important to do this after presentModalViewController
    CGRect bounds = self.view.bounds;
    CGPoint centerOfView = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    centerOfView = CGPointMake(0, 0);
    
    CGRect superview = nc.view.bounds;
    
    //nc.view.superview.center = CGPointMake(CGRectGetMidX(superview), CGRectGetMidY(superview));
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

            case ACTION_TUMBLR_LOGIN:
                [self tumblrLogin];
                break;
				
            case ACTION_TUMBLR_SHARE:
                [self tumblrShare];
                break;

            case ACTION_EMAIL_SHARE:
                [self emailShare];
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

# pragma mark - utilities
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

        NSRange end2;
		if (end.location == NSNotFound) {
			end2 = [[url substringFromIndex:start.location+start.length] rangeOfString:@"#"];
		} else {
			end2 = [[url substringWithRange:end] rangeOfString:@"#"];
		}

        NSUInteger offset = start.location+start.length;
        str = end2.location == NSNotFound
        ? [url substringFromIndex:offset]
        : [url substringWithRange:NSMakeRange(offset, end2.location)];
        str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return str;
}

/* Used for limiting the amount of characters allowed in the input text area */
- (void)textViewDidChange:(UITextView *)textView
{
	int remaining = maxTextCharacters - textView.text.length;
	twitterRemainingLabel.text = [NSString stringWithFormat:@"%d", remaining];
    if (remaining < 0) {
		twitterRemainingLabel.textColor = [UIColor colorWithRed:(188/255.f) green:0.f blue:0.f alpha:1.0];
		shareButton.enabled = NO;
		shareButton.alpha = 0.9;
    } else {
		twitterRemainingLabel.textColor = [UIColor blackColor];
		shareButton.enabled = YES;
		shareButton.alpha = 1;
	}
}

@end
