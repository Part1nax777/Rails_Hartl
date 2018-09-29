module SessionsHelper
	
	# Осуществляет вход данного пользователя
	def log_in(user)
	session[:user_id] = user.id
	end

	# Запомиинает пользователя в постояном сеансе
	def remember(user)
	  user.remember
	  cookies.permanent.signed[:user_id] = user.id
	  cookies.permanent[:remember_token] = user.remember_token
	end

	# Возвращает true, если данный пользователь является текущим
	def current_user?(user)
	user == current_user
	end


	# Возврат текущего пользователя
	def current_user 
	  if (user_id = session[:user_id])
	  @current_user ||= User.find_by(id: session[:user_id])
	  elsif (user_id = cookies.signed[:user_id])
	  user = User.find_by(id: user_id)
	  if user && user.authenticated?(:remember, cookies[:remember_token])
	  log_in user
	  @current_user = user
	end
	end
	end

	# Проверка зарегистрированного пользователя
	def logged_in?
	!current_user.nil?
	end

	# Закрывает постояный сеанс
	def forget(user)
	  user.forget
	  cookies.delete(:user_id)
	  cookies.delete(:remember_token)
	end

	#Выход текущего пользователя
	def log_out
	session.delete(:user_id)
	@current_user = nil
	end

	# Перенаправление по сохраненному адресу или на страницу по умолчанию
	def redirect_back_or(default)
	redirect_to(session[:forwarding_url] || default)
	session.delete(:forwarding_url)
	end

	# Запоминает URL
	def store_location
	session[:forwarding_url] = request.original_url if request.get?
	end	 
end
