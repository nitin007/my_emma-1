module MyEmma
  class Group
    include HTTParty
    base_uri "api.e2ma.net/#{$MYEMMA_CONFIG['account_id']}"
    basic_auth $MYEMMA_CONFIG['username'], $MYEMMA_CONFIG['password']
    format :json

    def all(options = {})
      HTTParty.get('/groups', options)
    end

  end
end
