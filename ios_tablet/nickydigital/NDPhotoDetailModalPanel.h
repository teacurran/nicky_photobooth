//
//  NDPhotoDetailModalPanel.h
//  nickydigital
//
//  Created by Terrence Curran on 2/12/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "UATitledModalPanel.h"

@interface NDPhotoDetailModalPanel : UATitledModalPanel <UITableViewDataSource> {
	UIView			*v;
	IBOutlet UIView	*viewLoadedFromXib;
}

@property (nonatomic, retain) IBOutlet UIView *viewLoadedFromXib;

@property (nonatomic, retain) IBOutlet UIImageView *photoView;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
- (IBAction)buttonPressed:(id)sender;
- (void)setPhoto:(UIImageView*)imageView;

@end
