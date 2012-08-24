module MyEmma
  class Group < RemoteObject

    API_ACCESSIBLE = [ :active_count, :group_type, :group_name ]

    API_PROTECTED = [:deleted_at, :error_count, :optout_count, :member_group_id, :account_id ]

    API_ATTRIBUTES = API_ACCESSIBLE + API_PROTECTED

    attr_accessor :group_name
    attr_reader :member_group_id

    def initialize( attr = {})
      super(attr)
    end

    def id
      self.member_group_id  
    end

    def self.all(options = {})
      set_http_values
      groups = get('/groups', options)
      found = []
      groups.each {|g| found << Group.new(g)} if self.operation_ok?(groups)
      found
    end

    def self.find(member_group_id)
      set_http_values
      g = get("/groups/#{member_group_id}")
      Group.new(g)
    end

    def self.find_by_group_name(group_name, options={})
      candidates = all(options)
      candidates.select { |g| g.group_name == group_name}.first
    end

    def save
      if self.persisted?

      else
        self.create
      end
    end

    def accessible_to_hash
      result = {}
      API_ACCESSIBLE.each do |key| 
        result[key] = instance_variable_get("@#{key}") if self.respond_to? key
      end
      result
    end

    def create
      Group.set_http_values
      response = Group.post('/groups', :body=> {:groups=>[self.accessible_to_hash]}.to_json)
      result = self.operation_ok?(response)
      @member_group_id = response[0]['member_group_id'] if result
      result
    end

    def update
      Group.set_http_values
      response = Group.put("/groups/#{self.member_group_id}", :body=> {:group_name => self.group_name})
      self.operation_ok?(response)
    end

  end
end
