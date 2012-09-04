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

#import "GRMustacheImplicitIteratorExpression_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheInvocation_private.h"

@implementation GRMustacheImplicitIteratorExpression
@synthesize debuggingToken=_debuggingToken;

+ (id)expression
{
    return [[[self alloc] init] autorelease];
}

- (void)dealloc
{
    [_debuggingToken release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    return [expression isKindOfClass:[GRMustacheImplicitIteratorExpression class]];
}


#pragma mark - GRMustacheExpression

- (id)valueForContext:(GRMustacheContext *)context filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates invocation:(GRMustacheInvocation **)ioInvocation
{
    if (delegates.count > 0) {
        NSAssert(ioInvocation, @"WTF");
        *ioInvocation = [[[GRMustacheInvocation alloc] init] autorelease];
        (*ioInvocation).debuggingToken = _debuggingToken;
        (*ioInvocation).returnValue = context.object;
        (*ioInvocation).key = @".";
    }
    
    return context.object;
}

@end
