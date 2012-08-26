module MyEmma

  class Member < RemoteObject

    attr_accessor :email, :status, :member_id

    API_PROTECTED = [:status, :confirmed_opt_in, :account_id, :member_id, :last_modified_at, :member_status_id,
                     :plaintext_preferred, :email_error, :member_since, :bounce_count, :deleted_at]

    SPECIAL_UPDATE_REQUIRED = [:email]

    @@known_attributes = Set.new

    def self.custom_attributes(*symbols)
      @@known_attributes.merge(symbols)
      nil
    end


    def initialize(attr = {})
      @groups = Array.new
      @groups_lazy_load_required = true
      attr = Member.load_attributes(attr)
      super(attr)
    end

    def self.find_by_email(email)
      set_http_values
      g = get("/members/email/#{email}")
      Member.new(g)
    end

    def self.find(member_id)
      set_http_values
      g = get("/members/#{member_id}")
      if g['error'].nil?
        Member.new(g)
      else
        nil
      end
    end

    def groups(reload = false)
      if (reload || @groups_lazy_load_required) && !self.member_id.nil?
        @api_groups = Group.find_all_by_member_id(self.member_id)
        @api_groups.each {|g| @groups << g unless @groups.map {|g1| g1.member_group_id }.include?(g.id) } 
        @groups_lazy_load_required = false
      end
      @groups
    end

    def add_group(group)
      @groups << group if group.id.nil? || !@groups.map {|g| g.member_group_id }.include?(group.id)
    end

    def save
      @groups.each { |group| group.save if group.member_group_id.nil? }
      self.import_single_member
    end

    protected

    def self.load_attributes(attr)
      if attr.has_key?('fields') then
        attr['fields'].each {|k,v| attr[k] = v}
      end
      puts "#{attr.to_yaml}"
      new_keys = attr.keys.map { |k| k.to_sym }
      new_keys.delete(:fields)
      @@known_attributes.merge(new_keys)
      @@accessible_attributes = @@known_attributes.clone.subtract(API_PROTECTED)
      attr
    end

    def self.accessible_attributes
      @@accessible_attributes
    end

    def self.api_attributes
      @@known_attributes
    end

    def fields
      result = Hash.new
      self.class.accessible_attributes.clone.subtract(SPECIAL_UPDATE_REQUIRED).each {|key|
        result[key] = instance_variable_get "@#{key}"
      }
      result
    end

    def import_single_member
      Member.set_http_values
      response = Member.post("/members/add",
                             :body=>{ :email=>self.email,
                                      :fields=>self.fields,
                                      :status_to=>self.status.nil? ? 'a' : self.status,
                                      :group_ids=>@groups.map{|g| g.member_group_id } }.to_json
                             )
      self.member_id = response['member_id'].to_i
      self.status = response['status']
      response
    end

  end

end
