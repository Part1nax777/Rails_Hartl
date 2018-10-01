require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

def setup 
	ActionMailer::Base.deliveries.clear
	@user = users(:serewka)
end

test "password resets" do
	get new_password_reset_path
	assert_template 'password_resets/new'
	
	# неверный адрес электронной почты
	post password_resets_path, params: { password_reset: { email: "" } }
	assert_not flash.empty?
	assert_template 'password_resets/new'

	# верный адрес электронной почты
	post password_resets_path, params: { password_reset: { email: @user.email } }
	assert_not_equal @user.reset_digest, @user.reload.reset_digest
	assert_equal 1, ActionMailer::Base.deliveries.size
	assert_not flash.empty?
	assert_redirected_to root_url

	# форма сброса пароля
	user = assigns(:user)
	
	# неверный адрес электронной почты
	get edit_password_reset_path(user.reset_token, email: "")
	assert_redirected_to root_url

	# неактивированная учётная запись 
	user.toggle!(:activated)
	get edit_password_reset_path(user.reset_token, email: user.email)
	assert_redirected_to root_url 
	user.toggle!(:activated)

	# верный адрес электронной почты, неверный токен 
	get edit_password_reset_path('wrong token', email: user.email)
	assert_redirected_to root_url

	# верный адрес электронной почты, верный токен
	get edit_password_reset_path(user.reset_token, email: user.email)
	assert_template 'password_resets/edit'
	assert_select "input[name=email][type=hidden][value=?]", @user.email

	# недопустимый пароль и подтверждение
	patch password_reset_path(user.reset_token),
	params: { email: user.email, user: { password: "foobaz", password_confirmation: "barquux" } }


	# пустой пароль
	patch password_reset_path(user.reset_token), 
	params: { email: user.email, user: { password: " ", password_confirmation: "foobar"} }
	assert_not flash.empty?
	assert_template 'password_resets/edit'

	# допустимый пароль и подтверждение
	patch password_reset_path(user.reset_token), 
	params: { email: user.email, user: { password: "foobaz", password_confirmation: "foobaz" } }
	assert is_logged_in?
	assert_not flash.empty?
	assert_redirected_to user
	end
end 
	 

