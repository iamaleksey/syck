# -*- mode: ruby; ruby-indent-level: 4; tab-width: 4 -*- vim: sw=4 ts=4
# $Id$
#
# = yaml/tag.rb: methods for associating a taguri to a class.
#
# Author:: why the lucky stiff
# 
module YAML
    # A dictionary of taguris which map to
    # Ruby classes.
    @@tagged_classes = {}
    
    # 
    # Associates a taguri _tag_ with a Ruby class _cls_.  The taguri is used to give types
    # to classes when loading YAML.  Taguris are of the form:
    #
    #   tag:authorityName,date:specific
    #
    # The +authorityName+ is a domain name or email address.  The +date+ is the date the type
    # was issued in YYYY or YYYY-MM or YYYY-MM-DD format.  The +specific+ is a name for
    # the type being added.
    # 
    # For example, built-in YAML types have 'yaml.org' as the +authorityName+ and '2002' as the
    # +date+.  The +specific+ is simply the name of the type:
    #
    #  tag:yaml.org,2002:int
    #  tag:yaml.org,2002:float
    #  tag:yaml.org,2002:timestamp
    #
    # The domain must be owned by you on the +date+ declared.  If you don't own any domains on the
    # date you declare the type, you can simply use an e-mail address.
    #
    #  tag:why@ruby-lang.org,2004:notes/personal
    #
    def YAML.tag_class( tag, cls )
        if @@tagged_classes.has_key? tag
            warn "class #{ @@tagged_classes[tag] } held ownership of the #{ tag } tag"
        end
        @@tagged_classes[tag] = cls
    end

    # Returns the complete dictionary of taguris, paired with classes.  The key for
    # the dictionary is the full taguri.  The value for each key is the class constant
    # associated to that taguri.
    #
    #  YAML.tagged_classes["tag:yaml.org,2002:int"] => Integer
    #
    def YAML.tagged_classes
        @@tagged_classes
    end
end

class Object # :nodoc: all
    class << self
        # Adds a taguri _tag_ to a class, used when dumping or loading the class
        # in YAML.  See YAML::tag_class for detailed information on typing and
        # taguris.
        def tag_as( tag )
            @@tag_as = tag
            @@tag_subclasses ||= true
            define_method( :tag_as ) do
                if @@tag_subclasses and self.class != YAML::tagged_classes[@@tag_as]
                    "#{ @@tag_as }:#{ self.class.tag_class_name }"
                else
                    @@tag_as
                end
            end
            define_method( :tag_subclasses? ) do
                @@tag_subclasses
            end
            YAML::tag_class tag, self
        end
        # Flags a class so that all subclasses fall under the same type
        # if _bool_ is true.
        def tag_subclasses?( bool )
            @@tag_subclasses = bool
        end
        # Transforms the subclass name into a name suitable for display
        # in a subclassed tag.
        def tag_class_name
            self.class.name
        end
        # Transforms the subclass name found in the tag into a Ruby
        # constant name.
        def tag_read_class( name )
            name
        end
    end
end