//
//  SNWebView.h
//

#import <UIKit/UIKit.h>

@interface MyWebView : UIWebView 
@end

@interface NSObject (MyWebViewDelegate)
- (void)touchesBegan:(NSSet*)touches inWebView:(UIWebView*)sender withEvent:(UIEvent*)event;
- (void)touchesMoved:(NSSet*)touches inWebView:(UIWebView*)sender withEvent:(UIEvent*)event;
- (void)touchesEnded:(NSSet*)touches inWebView:(UIWebView*)sender withEvent:(UIEvent*)event;
- (void)touchesCancelled:(NSSet*)touches inWebView:(UIWebView*)sender withEvent:(UIEvent*)event;
@end

