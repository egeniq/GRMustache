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

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros.h"

@class GRMustacheInvocation;
@class GRMustacheTemplate;

/**
 * A GRMustacheSection represents a Mustache section such as 
 * `{{#name}}...{{/name}}`.
 *
 * You will be provided with GRMustacheSection objects when implementing
 * mustache lambda sections with objects conforming to the GRMustacheHelper
 * protocol.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/helpers.md
 *
 * @see GRMustacheHelper
 *
 * @since v1.3
 */
@interface GRMustacheSection: NSObject {
@private
    id _sectionElement;
    id _renderingContext;
    id _filterContext;
    id _delegatingTemplate;
    id _delegates;
}


////////////////////////////////////////////////////////////////////////////////
/// @name Accessing the current rendering context
////////////////////////////////////////////////////////////////////////////////

/**
 * The current rendering context.
 *
 * @since v2.0
 * @deprecated v4.3
 */
@property (nonatomic, retain, readonly) id renderingContext AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_4_3;




////////////////////////////////////////////////////////////////////////////////
/// @name Accessing the literal inner content
////////////////////////////////////////////////////////////////////////////////

/**
 * The literal inner content of the section, with unprocessed Mustache
 * `{{tags}}`.
 *
 * @since v2.0
 */
@property (nonatomic, readonly) NSString *innerTemplateString AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Rendering the inner content
////////////////////////////////////////////////////////////////////////////////

/**
 * Renders the inner content of the receiver with the current rendering context.
 * 
 * @return A string containing the rendered inner content.
 *
 * @since v2.0
 */
- (NSString *)render AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Rendering another template string
////////////////////////////////////////////////////////////////////////////////

/**
 * Renders a template string with the current rendering context.
 *
 * @param string    A template string
 * @param outError  If there is an error loading or parsing template and
 *                  partials, upon return contains an NSError object that
 *                  describes the problem.
 *
 * @return A string containing the rendering of the template string.
 *
 * @since v4.3
 */
- (NSString *)renderTemplateString:(NSString *)string error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_4_3_AND_LATER;

@end
