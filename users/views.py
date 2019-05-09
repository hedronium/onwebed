from django.shortcuts import render, redirect
from django.contrib.auth import logout as auth_logout, authenticate, login as auth_login
from django.contrib import messages
from django.contrib.auth.models import User
from django.core.validators import validate_email
from django.core.exceptions import ValidationError

# Create your views here.

def index(request):
	data = {
		'userIsLoggedIn': request.user.is_authenticated,
		'user': request.user,
	}

	return render(request, "users/index.html", data)

def login(request):
	if request.user.is_authenticated:
		print("Hey")
		messages.info(request, "You are already logged in!")
		return redirect("users:index")

	if request.method == "POST":
		username = request.POST['username']
		password = request.POST['password']

		user = authenticate(request, username = username, password = password)

		if user is not None:
				auth_login(request, user)
				messages.success(request, "User logged in successfully!")
				return redirect("users:index")
		else:
			messages.error(request, "Incorrect credentials.")

	return render(request, "users/login.html")

def register(request):
	if request.user.is_authenticated:
		messages.info(request, "You are already logged in!")
		return redirect("users:index")

	if request.method == "POST":
		username = request.POST['username']
		email_address = request.POST['email_address']
		password = request.POST['password']
		confirm_password = request.POST['confirm_password']

		if password == confirm_password:
			if User.objects.filter(username = username).exists() == False:
				existing_email_address = User.objects.filter(email = email_address)

				if User.objects.filter(email = email_address).exists() == False:
					try:
						validate_email(email_address)
						
						if len(username) >= 3:
							if len(password) >= 3:
								user = User.objects.create_user(username, email_address, password)

								messages.success(request, "User registered successfully!")

								auth_login(request, user)

								return redirect("users:index")
							else:
								messages.error(request, "Password should be at least 3 characters long.")
						else:
							messages.error(request, "Username should be at least 3 characters long.")
					except ValidationError:
						messages.error(request, "Email Address not valid!")
				else:
					messages.error(request, "Email Address already taken! Try another one.")
			else:
				messages.error(request, "Username already taken! Try another one.")
		else:
			messages.error(request, "Passwords do not match!")

	return render(request, "users/register.html")


def logout(request):
	if request.user.is_authenticated:
		auth_logout(request)

	return redirect("users:index")