//
//  NDPhotoDetailModalPanel.m
//  nickydigital
//
//  Created by Terrence Curran on 2/12/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "NDPhotoDetailModalPanel.h"
#import "NDConstants.h"

#import "UAModalPanel.h"
#import "UARoundedRectView.h"

@implementation NDPhotoDetailModalPanel

@synthesize photoView;
@synthesize _content;



-(id)initWithFrame:(CGRect)frame content:(UIView*)content {

	self._content = content;
	
	if ((self = [super initWithFrame:frame])) {
		self.contentColor = [UIColor whiteColor];
		self.shouldBounce = NO;
	
		//[[NSBundle mainBundle] loadNibNamed:@"PhotoDetail" owner:self options:nil];
		//viewLoadedFromXib.frame = self.contentView.frame;

		_content.frame = self.contentView.frame;
		
		[self.contentView addSubview:self._content];
		
		
	}

	//The setup code (in viewDidLoad in your view controller)
	UITapGestureRecognizer *singleFingerTap =
	[[UITapGestureRecognizer alloc] initWithTarget:self
											action:@selector(closePressed:)];
	[self addGestureRecognizer:singleFingerTap];
	
	return self;
}

-(void)setPhoto:(UIImageView*)imageView {
	self.photoView.image = imageView.image;
	
}

- (CGRect)roundedRectFrame {
	
	// was: self.frame.size.height - self.margin.top - self.margin.bottom - 300
	int detailHeight = 575;
	
	return CGRectMake(self.margin.left + self.frame.origin.x,
					  self.margin.top + self.frame.origin.y,
					  self.frame.size.width - self.margin.left - self.margin.right,
					  detailHeight);
}





@end
