warn <<-STR
[DEPRECATION] #{Kernel.caller.first}
[DEPRECATION] `require 'consumer'` is deprecated.  File should now be correctly loaded using autoloading.
STR

require "responsible/consumer"
