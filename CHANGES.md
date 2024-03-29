## 1.4.2 - 3-Aug-2021
* Properly set the p_proto type (short, not int) for Windows.
* Minor updates suggested by rubocop.
* Added a Gemfile.

## 1.4.1 - 18-Feb-2021
* Switch rdoc format to markdown where appropriate.

## 1.4.0 - 17-Aug-2020
* Switched from test-unit to rspec.

## 1.3.1 - 30-Jul-2020
* Add a LICENSE file as required by the Apache-2.0 license.

## 1.3.0 - 10-Jan-2019
* Changed license to Apache-2.0.
* The VERSION constant is now frozen.
* Added metadata to the gemspec.
* Updated cert, should be good for about 10 years now.

## 1.2.1 - 4-Jan-2016
* This gem is now signed.
* The gem related tasks in the Rakefile now assume Rubygems 2.x.
* Added a net-proto.rb file for convenience.

## 1.2.0 - 3-Nov-2014
* The getprotobynumber and getprotobyname methods on MS Windows now accept
  optional window and message arguments. If used, the method becomes
  asynchronous and yields a block instead.

## 1.1.1 - 9-Oct-2014
* Implemented getprotoent on Windows using pure Ruby.
* Miscellaneous minor updates to the Rakefile, gemspec and docs.

## 1.1.0 - 18-Jan-2012
* Switched to FFI instead of C backend. Now works with JRuby, too.
* Added the generic get_protocol instance method that accepts either a
  string or an integer and does the right thing. This method should be
  preferred going forward.
* Documentation updates.
* Refactored the test suite to use features of test-unit 2.x.
* Added a default rake task.

## 1.0.6 - 22-Oct-2010
* Refactored the test suite and removed one test that was implementation
  dependent and not useful.
* Updates to the README and gemspec.

## 1.0.5 - 12-Sep-2009
* Changed license to Artistic 2.0.
* Added a build_binary_gem task.
* Cleaned up and refactored the gemspec a bit, including the addition of
  a license and an updated description.
* Switched test-unit from a runtime dependency to a dev dependency.

## 1.0.4 - 6-Jan-2008
* The struct returned by Net::Proto.getprotoent is now frozen. This is
  strictly read-only data.
* It is now explicitly illegal to call Net::Proto.new.
* Some minor modifications to extconf.rb in terms of how and where the
  the source is built in order to be potentially more friendly to Rubygems.
* Renamed and refactored the test suite. This library now requires test-unit
  version 2.0.2 or later.

## 1.0.3 - 13-Aug-2007
* Fix for OS X (whining about malloced pointer).
* Added a Rakefile along with tasks for installation and testing.
* Major internal reorganization.
* Fixed Proto::VERSION test.

## 1.0.2 - 18-Nov-2006
* Updated the README, gemspec and netproto.txt files.
* No code changes.

## 1.0.1 - 30-Jun-2006
* Added rdoc to the source files.
* Added a gemspec.

## 1.0.0 - 14-Jul-2005
* Moved project to RubyForge.
* Minor directory layout change.
* Minor changes to the extconf.rb file.
* Officially bumped VERSION to 1.0.0.

## 0.2.5 - 18-Apr-2005
* The Unix versions now call setprotoent(0) and endprotoent() internally
  before each call.

## 0.2.4 - 12-Apr-2005
* Added internal taint checking for the Proto.getprotobyname method.
* Removed the INSTALL file.  Installation instructions are now in the README.
* Moved the sample script into the 'examples' directory.
* General code cleanup.
* Minor test suite changes and additions.
* Removed the netproto.rd and netproto.html files.  The netproto.txt file is
  now rdoc friendly.

## 0.2.3 - 13-Sep-2004
* Replaced all instances of the deprecated STR2CSTR() function with the
  StringValuePtr() function.  That means that, as of this release, this
  package requires Ruby 1.8.0 or later.
* Minor documentation corrections.

## 0.2.2 - 10-Apr-2004
* No longer returns an Array in block form.  Only the non-block form returns
  an array.  The block form returns nil.
* Updated the documentation, warranty information included, license changed
  back to "Ruby's".
* Modified extconf.rb.  It is now assumed that you have TestUnit installed.
* Changed "tc_all.rb" to "tc_netproto.rb".
* Changed "netproto.rd2" to "netproto.rd".

## 0.2.1 - 29-Jul-2003
* Code cleanup (-Wall warnings on Linux)
* Removed VERSION() class method.  Use the constant instead
* The getprotoent() method now returns an array of structs in non-block form
* Added README file
* Added generic test script under test/
* Modified extconf.rb to use generic test script for those who don't have
  TestUnit installed, instead of dynamically generating one
* Fixed up TestUnit test suite

## 0.2.0 - 26-Feb-2003
* Added MS Windows support (except 'getprotoent()' - see docs)
* For protocols that aren't defined, nil is now returned instead
  of crashing (always a good thing)
* Removed sys-uname requirement
* Added a test suite (for those with testunit installed)
* Some internal layout changes (doc, lib, test dirs)
* Added a VERSION constant and class method
* RD2 documentation now separated from source
* Installation instructions modified
* Lots of changes to extconf.rb
* Changelog now CHANGES
* Manifest now MANIFEST
* Package name changed to lower case

## 0.1.0 - 13-Aug-2002
* Fixed bug with getprotoent_r function for Linux
* Added a 'generic' source file that uses the non-reentrant functions for
  those platforms that are not specifically supported.
* Added FreeBSD support
* Modified test script slightly
* Added a changelog :)
* Added a manifest
   
## 0.0.1 - 12-Aug-2002
* Initial release (though written earlier)
