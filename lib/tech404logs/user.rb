module Tech404logs
  class User
    include DataMapper::Resource
    storage_names[:default] = 'users'

    property :id, String, key: true
    property :name, String
    property :real_name, String
    property :image, String, length: 255

    def self.create_or_update(user)
      first_or_new(id: user.fetch('id')).tap do |record|
        record.name = user.fetch('name')
        record.real_name = user.fetch('profile').fetch('real_name')
        record.image = user.fetch('profile').fetch('image_48')
      end.save
    end

    def self.store(user_or_id)
      case user_or_id
      when Hash
        self.create_or_update(user_or_id)
      when String
        self.first_or_create(id: user_or_id)
      end
    end
  end
end
