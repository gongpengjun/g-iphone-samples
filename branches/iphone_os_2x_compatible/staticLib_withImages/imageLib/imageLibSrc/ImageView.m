//
//  ImageView.m
//

#import "ImageView.h"
#import "FGImage.h"

@implementation ImageView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		CGPoint position = self.center;
		
		UIImageView * imgView = [[UIImageView alloc] initWithImage:[FGImage imageWithDataNamed:@"Apple-Logo-50_X_50.gif"]];
		[self addSubview:imgView];
		position.y = 80.0;
		imgView.center = position;
		
		UILabel* imgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		imgLabel.textAlignment = UITextAlignmentCenter;
		imgLabel.backgroundColor = [UIColor clearColor];
		imgLabel.text = @"GIF";
		position.y += imgView.bounds.size.height/2.0;
		imgLabel.frame = CGRectMake(0,position.y,320.0,30.0);
		[self addSubview:imgLabel];
		
		[imgLabel release];
		[imgView release];
		
		imgView = [[UIImageView alloc] initWithImage:[FGImage imageWithDataNamed:@"Apple-Logo.png"]];
		[self addSubview:imgView];
		position.y = 200.0;
		imgView.center = position;
		
		imgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		imgLabel.textAlignment = UITextAlignmentCenter;
		imgLabel.backgroundColor = [UIColor clearColor];
		imgLabel.text = @"PNG";
		position.y += imgView.bounds.size.height/2.0;
		imgLabel.frame = CGRectMake(0,position.y,320.0,30.0);
		[self addSubview:imgLabel];
		
		[imgLabel release];
		[imgView release];
		
		imgView = [[UIImageView alloc] initWithImage:[FGImage imageWithDataNamed:@"50_X_50-Apple_Logo.jpg"]];
		[self addSubview:imgView];
		position.y = 300.0;
		imgView.center = position;
		
		imgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		imgLabel.textAlignment = UITextAlignmentCenter;
		imgLabel.backgroundColor = [UIColor clearColor];
		imgLabel.text = @"JPG";
		position.y += imgView.bounds.size.height/2.0;
		imgLabel.frame = CGRectMake(0,position.y,320.0,30.0);
		[self addSubview:imgLabel];
		
		[imgLabel release];
		[imgView release];
    }
    return self;
}

@end
