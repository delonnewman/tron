require 'digest'
require 'bcrypt'
require 'logger'
require 'monad/maybe'
require 'vista/hui_data'
require 'vista/kernel_hash'

module Tron
  class User < Sequel::Model
    many_to_many :permissions, join_table: :user_permissions

    LOG = Logger.new(STDOUT)
    LOG.level = if ENV['RACK_ENV'] == 'development' || ENV['RACK_ENV'].nil?
                  Logger::DEBUG
                else
                  Logger::ERROR
                end

    plugin :validation_helpers
    def validate
      super
      validates_unique :email
    end

    def self.authenticate?(params)
      !!authenticate(params)
    end

    def self.authenticate!(params)
      email = params[:email] || raise(':email is required')

      if (user = find email: email, activated: true) && user.authenticate!(params)
        user
      else
        nil
      end
    end

    def self.activate(params)
      p params
      find_by_email_and_activation_key(params[:email], params[:key]).to_maybe.activate(params).value
    end

    def self.activateable?(params)
      user = find_by_email_and_activation_key(params[:email], params[:key])
      if user.nil?
        false
      else
        if user.actication_expires_on.nil?
          false
        else
          user.activation_expires_on > Date.today
        end
      end
    end

    def self.find_by_email_and_activation_key(email, key)
      if (user = find email: email) && (user.activation_key == (key + user.activation_salt))
        user
      else
        nil
      end
    end

    def activation_key
      BCrypt::Password.new(crypted_activation_key)
    end

    def salted_access_code
      BCrypt::Password.new(crypted_access_code)
    end

    def authenticate!(params)
      access = params[:access] || raise(':access is required')

      if salted_access_code == access + salt
        vista_authenticate! params
      else
        LOG.debug("Given access code (#{access}) did not match stored access code")
        raise "There was an error logging in.  Make sure you entered your access code correctly, otherwise please see your system administrator"
      end
    end

    def email_authenticate?(params)
      key    = params[:key] or raise ':key is required'
      access = params[:access] or raise ':access is required'

      activation_key == key + activation_salt and salted_access_code == access + salt
    end

    def email_authenticate!(params)
      email_authenticate?(params) or raise "There was an error logging in. Make sure you entered your access code correctly, otherwise please see your system administator"
    end

    def vista_authenticate(params)
      site   = params[:site]   || raise(':site is required')
      access = params[:access] || raise(':access is required')
      verify = params[:verify] || raise(':verify is required')

      LOG.debug("access code: #{access}, verify code: #{verify}")
      res = Vista::HuiData.login site_code: site, access_code: Vista::KernelHash.encrypt(access), verify_code: Vista::KernelHash.encrypt(verify)
      LOG.debug("HuiData Login response: #{res.inspect}")
      res
    end

    def vista_authenticate?(params)
      res = vista_authenticate(params)
      p res
      if res.code != 0
        true
      else
        false
      end
    end

    def vista_authenticate!(params)
      res = vista_authenticate(params)
      if res.code != 0
        res.code
      else
        raise "There was an error authenticating with VistA credentials: #{res.message}"
      end
    end

    def activate(params)
      if vista_authenticate? params
        code = crypt(params[:access] + salt)
        update(activated: true, crypted_access_code: code)
      end
      self
    end

    alias activated? activated

    # Generates activation salt, key and crypted key + salt
    #     User#generate_activation_crypt # => [ key, salt, crypt ]
    #
    # where `key` is a SHA256 hash, `salt` is a SHA256 hash,
    # and `crypt` is an BCrypted concatenation of `key` and `salt`.
    def generate_activation_crypt
      salt  = Digest::SHA256.hexdigest(srand.to_s)
      key   = Digest::SHA256.hexdigest(srand.to_s)
      crypt = BCrypt::Password.create(key + salt)
      [ key, salt, crypt ]
    end

    # Uses `User#generate_activation_crypt` to generate a key,
    # salt and crypted key, saves the crypted key and salt to
    # the data base and returns the key.
    #     User#set_activation_key! # => key
    #
    # where `key` is a SHA256 hash.
    #
    # See User#generate_activation_crypt
    def set_activation_key!(expiration=nil)
      key, salt, crypt = generate_activation_crypt
      update(crypted_activation_key: crypt, activation_salt: salt, activation_expires_on: expiration || (Date.today + 1))
      key
    end

    def grant(per, args={})
      app = eval_sym(args[:for] || raise('application is required, specified by :for'), Application)
      
      p = Permission.find(name: eval_sym(per, Permission).to_maybe.name.to_s) || raise("Cannot find permission #{per.inspect}")
      raise "Cannot grant permission #{p} for #{app}, #{p} works only for #{p.application}" unless p.application.nil? or app == p.application

      UserPermission.create user: self, permission: eval_sym(per, Permission), application: app
    end

    def can?(per, args={})
      app = args[:for]

      if app
        u = UserPermission.find user: self, permission_id: eval_sym(per, Permission).to_maybe.id.value, application: eval_sym(app, Application)
        not u.nil?
      else
        ps = Permission.where(name: eval_sym(per, Permission).to_maybe.name.to_s).map(&:users).select { |us| us.include?(self) }
        not ps.empty?
      end
    end

    def cannot?(per, args={})
      not can?(per, args || {})
    end

    def to_s
      name
    end

    def to_url(*path)
      (["/users/#{id}"] + path).join('/')
    end

    private

    def eval_sym(obj, klass)
      obj.is_a?(Symbol) ? klass.find(name: obj.to_s) : obj
    end

    def crypt(str)
      BCrypt::Password.create(str)
    end
  end
end
