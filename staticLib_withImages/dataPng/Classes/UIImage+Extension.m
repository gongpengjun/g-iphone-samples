//
//  UIImage+Extension.m
//

#import "UIImage+Extension.h"
#import "images.h"

@implementation UIImage (Extension)

/*
 There's a little app called bin2c ( http://wiki.wxwidgets.org/Embedding_PNG_Images-Bin2c_In_C) 
 which can be used to easily make char* arrays. You can then use it
 to create a CGImage/UIImage with CGDataProviderCreateWithData() and
 CGImageCreateWithPNGDataProvider().
 
 Or NSData's initWithBytesNoCopy:... :) 
 */
+ (id)imageWithDataNamed:(NSString*)imageName
{
	NSString *imageArraryName = [imageName stringByReplacingOccurrencesOfString:@"." withString:@"_"];
	unsigned char* bytes = byte_array_of_image([imageArraryName UTF8String]);
	unsigned int   size  = byte_size_of_image([imageArraryName UTF8String]);
	UIImage * image = [UIImage imageWithData:[NSData dataWithBytesNoCopy:bytes length:size]];
	return image;
}

@end
