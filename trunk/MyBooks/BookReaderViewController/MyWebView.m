//
//  MyWebView.m
//

#import "MyWebView.h"
#if TARGET_IPHONE_SIMULATOR
	#import <objc/objc-runtime.h>
#else
	#import <objc/runtime.h>
#endif

const char* kUIWebDocumentView= "UIWebDocumentView";

@interface MyWebView (private)
- (void)hookedTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)hookedTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)hookedTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)hookedTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@implementation UIView (__TapHook)

- (void)__replacedTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	[self __replacedTouchesBegan:touches withEvent:event];		// call @selector(touchesBegan:withEvent:)
	if( [self.superview.superview isMemberOfClass:[MyWebView class]] ) {
		[(MyWebView*)self.superview.superview hookedTouchesBegan:touches withEvent:event];
	}
}
- (void)__replacedTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	[self __replacedTouchesMoved:touches withEvent:event];		// call @selector(touchesMoved:withEvent:)
	if( [self.superview.superview isMemberOfClass:[MyWebView class]] ) {
		[(MyWebView*)self.superview.superview hookedTouchesMoved:touches withEvent:event];
	}
}

- (void)__replacedTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	[self __replacedTouchesEnded:touches withEvent:event];		// call @selector(touchesEnded:withEvent:)
	if( [self.superview.superview isMemberOfClass:[MyWebView class]] ) {
		[(MyWebView*)self.superview.superview hookedTouchesEnded:touches withEvent:event];
	}
}

- (void)__replacedTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	[self __replacedTouchesCancelled:touches withEvent:event];	// call @selector(touchesCancelled:withEvent:)
	if( [self.superview.superview isMemberOfClass:[MyWebView class]] ) {
		[(MyWebView*)self.superview.superview hookedTouchesCancelled:touches withEvent:event];
	}
}

@end

static BOOL isAlreaddHookInstalled = NO;

@implementation MyWebView

#pragma mark Class method setup hookmethod for UIWebDocumentView

+ (void)installHook {
	if( isAlreaddHookInstalled )
		return;
	isAlreaddHookInstalled = YES;
	
	Class klass = objc_getClass( kUIWebDocumentView );
	
	if( klass == nil )
		return;		// if there is no UIWebDocumentView in the future.
	
	// replace touch began event
	method_exchangeImplementations(
					class_getInstanceMethod(klass, @selector(touchesBegan:withEvent:)), 
					class_getInstanceMethod(klass, @selector(__replacedTouchesBegan:withEvent:)) );
	
	// replace touch moved event
	method_exchangeImplementations(
					class_getInstanceMethod(klass, @selector(touchesMoved:withEvent:)), 
					class_getInstanceMethod(klass, @selector(__replacedTouchesMoved:withEvent:))
	);
	
	// replace touch ended event
	method_exchangeImplementations(
					class_getInstanceMethod(klass, @selector(touchesEnded:withEvent:)), 
					class_getInstanceMethod(klass, @selector(__replacedTouchesEnded:withEvent:))
	);
	
	// replace touch cancelled event
	method_exchangeImplementations(
					class_getInstanceMethod(klass, @selector(touchesCancelled:withEvent:)), 
					class_getInstanceMethod(klass, @selector(__replacedTouchesCancelled:withEvent:))
	);
}

#pragma mark Original method for call delegate method

- (void)hookedTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"%s",__FUNCTION__);
	if( [self.delegate respondsToSelector:@selector(touchesBegan:inWebView:withEvent:)] )
		[(NSObject*)self.delegate touchesBegan:touches inWebView:self withEvent:event];
}

- (void)hookedTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if( [self.delegate respondsToSelector:@selector(touchesMoved:inWebView:withEvent:)] )
		[(NSObject*)self.delegate touchesMoved:touches inWebView:self withEvent:event];
}

- (void)hookedTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if( [self.delegate respondsToSelector:@selector(touchesEnded:inWebView:withEvent:)] )
		[(NSObject*)self.delegate touchesEnded:touches inWebView:self withEvent:event];
}

- (void)hookedTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if( [self.delegate respondsToSelector:@selector(touchesCancelled:inWebView:withEvent:)] )
		[(NSObject*)self.delegate touchesCancelled:touches inWebView:self withEvent:event];
}

#pragma mark override

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[MyWebView installHook];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder {
    if (self = [super initWithCoder:coder]) {
		[MyWebView installHook];
    }
    return self;
}

@end
