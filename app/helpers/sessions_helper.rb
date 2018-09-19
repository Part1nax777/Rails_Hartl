module SessionsHelper
	
	# Осуществляет вход данного пользователя
	def log_in(user)
	session[:user_id] = user.id
	end

	# Возврат текущего пользователя
	def current_user 
	@current_user ||= User.find_by(id: session[:user_id])
	end

	# Проверка зарегистрированного пользователя
	def logged_in?
	!current_user.nil?
	end
end
