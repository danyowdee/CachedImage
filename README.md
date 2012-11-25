# What’s this?

`UIImage` has a clever mechanism for loading images:
Its `+imageNamed` class-method will attempt to retrieve an appropriate image for the `name` you pass in, caching the image in memory for later reuse to avoid unnecessary IO-overhead.
What’s even better, is that it purges the backing pixel buffers in situations of memory pressure, (provided they aren’t currently needed) and re-populates them when needed again!

Unfortunately, this mechanism only searches the main bundle of your app. I.e. if you have separate bundles for modularized resource-management, you <del>are pretty much f</del> cannot use it!

This library adds similar caching support for secondary bundles through a single-method category on `UIImage`. And, because I like code uniformity, it falls through to `+[UIImage imageNamed:]` whenever you pass in `nil` or the main bundle as the `bundle` argument.

# Special Considerations
The implementation is pretty trivial. But you shouldn’t use this code if you don’t feel comfortable with using a little runtime magic. (See the implementation of `+[UIImage(D12_SecondaryBundleCacheSupport) load]` to find out what I mean.)

You can, however, chose to remove this bit because unloading bundles is pretty uncommon, anyways.

# License
This code is published under the terms of the BSD 2-clause License. I.e. you can basically do what you want with it, as long as you give proper attribution. For your convenience, the license is reproduced here as well:

Copyright (c) 2012, Dock12
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
