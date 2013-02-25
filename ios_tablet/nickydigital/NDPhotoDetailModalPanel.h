//
//  NDPhotoDetailModalPanel.h
//  nickydigital
//
//  Created by Terrence Curran on 2/12/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "UATitledModalPanel.h"

@interface NDPhotoDetailModalPanel : UAModalPanel {
	UIView      *v;
}

@property (nonatomic, retain) IBOutlet UIView *_content;

@property (nonatomic, retain) IBOutlet UIImageView *photoView;

@property (nonatomic, retain) UAModalPanel *detailPanel;

-(id)initWithFrame:(CGRect)frame content:(UIView*)content;
-(void)setPhoto:(UIImageView*)imageView;


@end
