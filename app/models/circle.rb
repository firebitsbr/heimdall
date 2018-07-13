class Circle
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamps::Model
  field :name, type: String
  resourcify
  has_and_belongs_to_many :evaluations
  has_and_belongs_to_many :profiles
  validates_presence_of :name

  def recents
    recents = {}
    recents = fill_recents(recents, evaluations)
    recents = fill_recents(recents, profiles)
    recents = fill_recents(recents, User.with_role(:owner, self))
    recents = fill_recents(recents, User.with_role(:member, self))

    recents = Hash[recents.sort_by { |key, _| key }]
    ret_hsh = {}
    recents.each do |tl, ary|
      ret_hsh[tl] = ary.sort
    end
    ret_hsh
  end

  def fill_recents(recents, recent_objs)
    recent_objs.each do |obj|
      next if obj.created_at.nil?
      key = obj.created_at.strftime('%d %b.%Y')
      recents[key] = [] unless recents.key?(key)
      recents[key] << obj
    end
    recents
  end
end