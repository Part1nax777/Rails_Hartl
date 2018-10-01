class User < ApplicationRecord

	attr_accessor :remember_token, :activation_token, :reset_token
	before_save { self.email = email.downcase }
	before_create :create_activation_digest
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true

	# возвращает дайджест дл€ случайной строки
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

	# запоминает пользовател€ в базе данных дл€ использовани€ в посто€нных сеансах
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

	# забыть пользовател€
	def forget
	  update_attribute(:remember_digest, nil)
	end

	# јктивирует учЄтную запись
	def activate
	update_attribute(:activated, true)
	update_attribute(:activated_at, Time.zone.now)
	end

	# ѕосылает письмо со ссылкой на страницу активации
	def send_activation_email
	UserMailer.account_activation(self).deliver_now
	end

	# ”станавливает атрибуты дл€ сброса парол€
	def create_reset_digest
	self.reset_token = User.new_token
	update_attribute(:reset_digest, User.digest(reset_token))
	update_attribute(:reset_sent_at, Time.zone.now)
	end

	# ѕосылает письмо со ссылкой на форму ввода нового парол€
	def send_password_reset_email
	UserMailer.password_reset(self).deliver_now
	end

	# ¬озвращает true если врем€ парол€ истекло
	def password_reset_expired?
	reset_sent_at < 2.hours.ago
	end

private

	# ѕреобразует адрес электронной почты в нижний регистр
	def downcase_email
	self_email = email.downcase
	end

	# —оздает и присваивает токен активации и его дайджест
	def create_activation_digest
	self.activation_token = User.new_token
	self.activation_digest = User.digest(activation_token)
	end
end
