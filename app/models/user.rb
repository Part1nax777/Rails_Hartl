class User < ApplicationRecord

	has_many :microposts, dependent: :destroy
	has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
	has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
	has_many :following, through: :active_relationships, source: :followed
	has_many :followers, through: :passive_relationships, source: :follower

	attr_accessor :remember_token, :activation_token, :reset_token
	
	before_save { self.email = email.downcase }
	before_create :create_activation_digest
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true

	# возвращает дайджест для случайной строки
	def User.digest(string)
	  cost = ActiveModel::SecurePassword.min_cost ?
	  BCrypt::Engine::MIN_COST :
	  BCrypt::Engine.cost
	BCrypt::Password.create(string, cost: cost)
	end
	
	# возвращает случайный токен
	def User.new_token	
	  SecureRandom.urlsafe_base64
	end

	# запоминает пользователя в базе данных для использования в постоянных сеансах
	def remember
	  self.remember_token = User.new_token
	  update_attribute(:remember_digest, User.digest(remember_token))
	end

	# возвращает true если токен соответствует дайджесту
	def authenticated?(attribute, token)
	  digest = send("#{attribute}_digest")
	  return false if digest.nil?
	  BCrypt::Password.new(digest).is_password?(token)
	end

	# забыть пользователя
	def forget
	  update_attribute(:remember_digest, nil)
	end

	# Активирует учётную запись
	def activate
	update_attribute(:activated, true)
	update_attribute(:activated_at, Time.zone.now)
	end

	# Посылает письмо со ссылкой на страницу активации
	def send_activation_email
	UserMailer.account_activation(self).deliver_now
	end

	# Устанавливает атрибуты для сброса пароля
	def create_reset_digest
	self.reset_token = User.new_token
	update_attribute(:reset_digest, User.digest(reset_token))
	update_attribute(:reset_sent_at, Time.zone.now)
	end

	# Посылает письмо со ссылкой на форму ввода нового пароля
	def send_password_reset_email
	UserMailer.password_reset(self).deliver_now
	end

	# Возвращает true если время пароля истекло
	def password_reset_expired?
	reset_sent_at < 2.hours.ago
	end

	# Определяет прото ленту
	# Полная реализация в 12 главе
	def feed
	following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
	Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
	end

	# Выполняет подписку на сообщения пользователя
	def follow(other_user)
	following << other_user
	end

	# Отменяет подписку на сообщения пользователя
	def unfollow(other_user)
	following.delete(other_user)
	end

	# Возвращает true если текущий пользователь читает другого пользователя
	def following?(other_user)
	following.include?(other_user)
	end

private    

	# Преобразует адрес электронной почты в нижний регистр
	def downcase_email
	self_email = email.downcase
	end

	# Создает и присваивает токен активации и его дайджест
	def create_activation_digest
	self.activation_token = User.new_token
	self.activation_digest = User.digest(activation_token)
	end
end
