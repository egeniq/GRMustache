// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustacheSectionElement_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheHelper.h"
#import "GRMustacheRenderingElement_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheSection_private.h"
#import "GRMustacheTemplateDelegate.h"

@interface GRMustacheSectionElement()

/**
 * The rendering of Mustache sections depend on the object they are attached to,
 * whether they are truthy, falsey, enumerable, or helpers. The object is
 * fetched by applying this expression to a rendering context.
 */
@property (nonatomic, retain) id<GRMustacheExpression> expression;

/**
 * The template string containing the inner template string of the section.
 */
@property (nonatomic, retain) NSString *templateString;

/**
 * The range of the inner template string of the section in `templateString`.
 */
@property (nonatomic) NSRange innerRange;

/**
 * YES if the section is {{^inverted}}; otherwise, NO.
 */
@property (nonatomic) BOOL inverted;

/**
 * The GRMustacheRenderingElement objects that make the section.
 * 
 * @see GRMustacheRenderingElement
 */
@property (nonatomic, retain) NSArray *elems;

/**
 * @see +[GRMustacheSectionElement sectionElementWithExpression:templateString:innerRange:inverted:elements:]
 */
- (id)initWithExpression:(id<GRMustacheExpression>)expression templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems;
@end


@implementation GRMustacheSectionElement
@synthesize templateString=_templateString;
@synthesize innerRange=_innerRange;
@synthesize expression=_expression;
@synthesize inverted=_inverted;
@synthesize elems=_elems;

+ (id)sectionElementWithExpression:(id<GRMustacheExpression>)expression templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems
{
    return [[[self alloc] initWithExpression:expression templateString:templateString innerRange:innerRange inverted:inverted elements:elems] autorelease];
}

- (void)dealloc
{
    [_expression release];
    [_templateString release];
    [_elems release];
    [super dealloc];
}

- (NSString *)innerTemplateString
{
    return [_templateString substringWithRange:_innerRange];
}

- (NSString *)renderElementsWithRenderingContext:(GRMustacheContext *)renderingContext filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates
{
    NSMutableString *result = [NSMutableString string];
    @autoreleasepool {
        for (id<GRMustacheRenderingElement> elem in _elems) {
            [result appendString:[elem renderRenderingContext:renderingContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates]];
        }
    }
    return result;
}

#pragma mark <GRMustacheRenderingElement>

- (NSString *)renderRenderingContext:(GRMustacheContext *)renderingContext filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates
{
    NSString *result = nil;
    @autoreleasepool {
        
        // evaluate
        
        GRMustacheInvocation *invocation = nil;
        id object = [_expression valueForContext:renderingContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates invocation:&invocation];
        if (invocation) {
            [delegatingTemplate invokeDelegates:delegates willInterpretReturnValueOfInvocation:invocation as:GRMustacheInterpretationSection];
            object = invocation.returnValue;
        }
        
        
        // augment delegates if necessary
        NSArray *innerDelegates = delegates;
        if ([object conformsToProtocol:@protocol(GRMustacheTemplateDelegate)]) {
            if (innerDelegates) {
                innerDelegates = [[NSArray arrayWithObject:object] arrayByAddingObjectsFromArray:innerDelegates];
            } else {
                innerDelegates = [NSArray arrayWithObject:object];
            }
        }
        
        // interpret
        
        if (object == nil ||
            object == [NSNull null] ||
            ([object isKindOfClass:[NSNumber class]] && [((NSNumber*)object) boolValue] == NO) ||
            ([object isKindOfClass:[NSString class]] && [((NSString*)object) length] == 0))
        {
            // False value
            if (_inverted) {
                result = [[self renderElementsWithRenderingContext:renderingContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:innerDelegates] retain];
            }
        }
        else if ([object isKindOfClass:[NSDictionary class]])
        {
            // True object value
            if (!_inverted) {
                GRMustacheContext *innerContext = [renderingContext contextByAddingObject:object];
                result = [[self renderElementsWithRenderingContext:innerContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:innerDelegates] retain];
            }
        }
        else if ([object conformsToProtocol:@protocol(NSFastEnumeration)])
        {
            // Enumerable
            if (_inverted) {
                BOOL empty = YES;
                for (id object2 in object) {
                    empty = NO;
                    break;
                }
                if (empty) {
                    result = [[self renderElementsWithRenderingContext:renderingContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:innerDelegates] retain];
                }
            } else {
                result = [[NSMutableString string] retain];
                for (id object2 in object) {
                    GRMustacheContext *innerContext = [renderingContext contextByAddingObject:object2];
                    NSString *itemRendering = [self renderElementsWithRenderingContext:innerContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:innerDelegates];
                    [(NSMutableString *)result appendString:itemRendering];
                }
            }
        }
        else if ([object conformsToProtocol:@protocol(GRMustacheHelper)])
        {
            // Helper
            if (!_inverted) {
                GRMustacheSection *section = [GRMustacheSection sectionWithSectionElement:self renderingContext:renderingContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:innerDelegates];
                result = [[(id<GRMustacheHelper>)object renderSection:section] retain];
            }
        }
        else
        {
            // True object value
            if (!_inverted) {
                GRMustacheContext *innerContext = [renderingContext contextByAddingObject:object];
                result = [[self renderElementsWithRenderingContext:innerContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:innerDelegates] retain];
            }
        }
        
        // finish
        
        if (invocation) {
            [delegatingTemplate invokeDelegates:delegates didInterpretReturnValueOfInvocation:invocation as:GRMustacheInterpretationSection];
        }

    }
    if (!result) {
        return @"";
    }
    return [result autorelease];
}


#pragma mark Private

- (id)initWithExpression:(id<GRMustacheExpression>)expression templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems
{
    self = [self init];
    if (self) {
        self.expression = expression;
        self.templateString = templateString;
        self.innerRange = innerRange;
        self.inverted = inverted;
        self.elems = elems;
    }
    return self;
}

@end
