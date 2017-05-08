module Binda
  class FieldSetting < ApplicationRecord

  	# Associations
  	belongs_to :field_group
    # has_many   :field_children, class_name: ::Binda::FieldSetting, dependent: :delete_all
    has_ancestry orphan_strategy: :destroy

  	# Fields Associations
  	# -------------------
  	# If you add a new field remember to update:
  	#   - get_fieldables (see here below)
  	#   - get_field_types (see here below)
  	#   - component_params (app/controllers/binda/components_controller.rb)
  	has_many :texts,         as: :fieldable
  	has_many :dates,         as: :fieldable
  	has_many :galleries,     as: :fieldable
    has_many :assets,        as: :fieldable
  	has_many :repeater,      as: :fieldable

  	# The following direct association is used to securely delete associated fields
  	# Infact via `fieldable` the associated fields might not be deleted 
  	# as the fieldable_id is related to the `component` rather than the `field_setting`
  	has_many :texts,         dependent: :delete_all
  	has_many :dates,         dependent: :delete_all
  	has_many :galleries,     dependent: :delete_all
    has_many :repeater,      dependent: :delete_all

    # accepts_nested_attributes_for :children, allow_destroy: true, reject_if: :is_rejected


  	def self.get_fieldables
  		%w( Text Date Gallery Asset Repeater )
  	end

  	# Field types are't fieldable! watch out! They might use the same model (eg `string` and `text`)
	  def get_field_types
	  	%w( string text asset gallery repeater date )
	  end

		# Validations
		validates :name, presence: true
		# validates :field_type, presence: true, inclusion: { in: :get_field_types }
    validates :field_group_id, presence: true

  	# Slug
		extend FriendlyId
		friendly_id :default_slug, use: [:slugged, :finders]


		# CUSTOM METHODS
		# --------------
	  # https://github.com/norman/friendly_id/issues/436
	  def should_generate_new_friendly_id?
	    slug.blank?
	  end

	  def default_slug
      breadcrumb = self.field_group.structure.name
      
      breadcrumb << '-'
      breadcrumb << self.field_group.name

      unless self.parent.nil?
        breadcrumb << '-' 
        breadcrumb << self.parent.name 
      end

	  	possible_names = [ 
        "#{ breadcrumb }--#{ self.name }",
	  		"#{ breadcrumb }--#{ self.name }-1",
	  		"#{ breadcrumb }--#{ self.name }-2",
	  		"#{ breadcrumb }--#{ self.name }-3" 
      ]

      return possible_names
	  end

  	# This will be use to overcome cascade delete on fieldable polymorphic association
  	# Infact fieldables aren't actually associated in the DB, they are associated with components!
  	# def self.get_deletable_fieldables
  	# 	self.get_fieldables - %w( Asset )
  	# end

  	# def delete_fieldables
  	# 	self.get_deletable_fieldables.each do |fieldable|
  	# 		F = fieldable.constantize
  	# 		F.where( field_setting_id:  )
  	# 	end
  	# end


  end
end
