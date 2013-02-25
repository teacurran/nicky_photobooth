//
//  NDPhotoDetailModalPanel.m
//  nickydigital
//
//  Created by Terrence Curran on 2/12/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "NDPhotoDetailModalPanel.h"
#import "NDConstants.h"

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
	
	return self;
}


-(void)setPhoto:(UIImageView*)imageView {
	self.photoView.image = imageView.image;
	
}





@end
