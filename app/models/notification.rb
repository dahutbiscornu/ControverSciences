class Notification < ActiveRecord::Base
  belongs_to :user

  attr_accessor :timeline_ids
  attr_accessor :reference_ids
  attr_accessor :comment_ids
  attr_accessor :sel_comment_ids
end
