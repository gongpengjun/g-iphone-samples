//
//  RootViewController.m
//

#import "RootViewController.h"
#import "ImageView.h"

@implementation RootViewController

- (void)loadView {
	
	self.title = @"ImageView Library Test";
	
	UIView * contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.view = contentView;
	[contentView release];

	ImageView * imgView = [[ImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	//[self.view addSubview:imgView];
	[imgView release];
}

@end
