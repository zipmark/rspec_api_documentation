# Aruba has an important step that is only on git right now, so we need to
# explicitly load the development bundle because gemspecs can't point to git
require "bundler"
Bundler.setup(:development)

require "aruba/cucumber"
