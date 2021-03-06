class User < ActiveRecord::Base
  validates :username, :password_digest, :session_token, presence: true
  validates :password, length: { minimum: 4, allow_nil: true }
  validates :session_token, uniqueness: true
  after_initialize :ensure_session_token

  attr_reader :password

  has_many :subs,
    primary_key: :id,
    foreign_key: :moderator_id,
    class_name: :Sub,
    inverse_of: :moderator

  has_many :posts,
    primary_key: :id,
    foreign_key: :author_id,
    class_name: :Post,
    inverse_of: :author

  has_many :comments,
    primary_key: :id,
    foreign_key: :author_id,
    class_name: :Comment

  def self.generate_session_token
    SecureRandom::urlsafe_base64(32)
  end

  def reset_session_token!
    self.session_token = User.generate_session_token
    self.save
    self.session_token
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def has_correct_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def self.find_by_credentials(username, password)
    @user = User.find_by(username: username)
    return nil unless @user
    return @user if @user.has_correct_password?(password)
    nil
  end

  def ensure_session_token
    self.session_token ||= User.generate_session_token
  end
end
