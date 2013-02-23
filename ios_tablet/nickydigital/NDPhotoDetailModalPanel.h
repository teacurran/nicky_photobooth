//
//  NDPhotoDetailModalPanel.h
//  nickydigital
//
//  Created by Terrence Curran on 2/12/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "UATitledModalPanel.h"

@interface NDPhotoDetailModalPanel : UIViewController<UIWebViewDelegate> {
	IBOutlet UIView	*viewLoadedFromXib;
}

@property (nonatomic, retain) IBOutlet UIView *viewLoadedFromXib;

@property (nonatomic, retain) IBOutlet UIImageView *photoView;

@property (nonatomic, retain) UAModalPanel *detailPanel;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
- (void)setPhoto:(UIImageView*)imageView;

- (IBAction)btnFacebookShareClick:(id)sender;

- (void)webViewDidFinishLoad:(UIWebView *)webView;

-(id)initWithFrame:(CGRect)frame;

@end
