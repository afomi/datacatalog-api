require File.expand_path(File.dirname(__FILE__) + '/../require_helpers')
require_file 'test/test_helper'
Config.setup_mongomapper
require_dir 'models'
require_dir 'observers'
require_dir 'helpers'