//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

#import "UINavigationController+BackSwizzling.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation UINavigationController (BackSwizzling)

// copy-paste from https://nshipster.com/method-swizzling/
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(navigationBar:shouldPopItem:);
        SEL swizzledSelector = @selector(xxx_navigationBar:shouldPopItem:);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling

- (BOOL)xxx_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    // only if we should pop
    BOOL shouldPop = [self xxx_navigationBar:navigationBar shouldPopItem:item];
    if (!shouldPop) { return shouldPop; }

    // find previous navigation item
    NSUInteger itemIndex = [navigationBar.items indexOfObject:item];
    if (itemIndex == NSNotFound || itemIndex < 1) { return shouldPop; }
    UINavigationItem *previousItem = navigationBar.items[itemIndex - 1];

    // get its target and action
    SEL selector = previousItem.backBarButtonItem.action;
    id target = previousItem.backBarButtonItem.target;
    if (!target || !selector) { return shouldPop; }

    // invoke target and action dynamically, otherwise the method selector will be leaked (compiler warning)
    // see https://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown

    // get method implementation
    IMP imp = [target methodForSelector:selector];
    // cast to a C function type
    void (*func)(id, SEL, id) = (void *)imp;
    // pass target, selector and method argument (sender) to the method
    func(target, selector, previousItem.backBarButtonItem);
    // return what we got
    return shouldPop;
}

@end
