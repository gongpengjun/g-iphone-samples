//
//  RootViewController.m
//

#import "RootViewController.h"
#import "UIImage+Extension.h"

@implementation RootViewController

- (void)dealloc {
    [super dealloc];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	self.title = @"Image From Byte Array";
	
	UIView * contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.view = contentView;
	[contentView release];

	CGPoint position = self.view.center;
	
	UIImageView * imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithDataNamed:@"Apple_Logo.gif"]];
	[self.view addSubview:imgView];
	position.y = 80.0;
	imgView.center = position;

	UILabel* imgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	imgLabel.textAlignment = UITextAlignmentCenter;
	imgLabel.backgroundColor = [UIColor clearColor];
	imgLabel.text = @"GIF";
	position.y += imgView.bounds.size.height/2.0;
	imgLabel.frame = CGRectMake(0,position.y,320.0,30.0);
	[self.view addSubview:imgLabel];
	
	[imgLabel release];
	[imgView release];
	
	imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithDataNamed:@"Apple_Logo.png"]];
	[self.view addSubview:imgView];
	position.y = 200.0;
	imgView.center = position;
	
	imgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	imgLabel.textAlignment = UITextAlignmentCenter;
	imgLabel.backgroundColor = [UIColor clearColor];
	imgLabel.text = @"PNG";
	position.y += imgView.bounds.size.height/2.0;
	imgLabel.frame = CGRectMake(0,position.y,320.0,30.0);
	[self.view addSubview:imgLabel];
	
	[imgLabel release];
	[imgView release];
	
	imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithDataNamed:@"Apple_Logo.jpg"]];
	[self.view addSubview:imgView];
	position.y = 300.0;
	imgView.center = position;
	
	imgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	imgLabel.textAlignment = UITextAlignmentCenter;
	imgLabel.backgroundColor = [UIColor clearColor];
	imgLabel.text = @"JPG";
	position.y += imgView.bounds.size.height/2.0;
	imgLabel.frame = CGRectMake(0,position.y,320.0,30.0);
	[self.view addSubview:imgLabel];
	
	[imgLabel release];
	[imgView release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end
