//
//  SBViewController.m
//  smilebooth
//
//  Created by Terrence Curran on 1/10/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "SBViewController.h"
#import "NDConstants.h"

@interface SBViewController ()

@end

@implementation SBViewController

- (void)loadView
{
    [super loadView];
    
    self.view.frame = self.view.bounds;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnFacebookShareClick:(id)sender {
    
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
    
    [self presentViewController:modalDialog animated:YES completion:^{
        // nothing
    }];
    
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
        
        [[[UIAlertView alloc]
          initWithTitle:@"OAuth Token"
          message: oauthToken
          delegate:self
          cancelButtonTitle:@"Ok"
          otherButtonTitles: nil] show];
        
        return false;
    }
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSString *url = [[[webView request] URL] absoluteString];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}


@end
