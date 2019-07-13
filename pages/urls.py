from django.urls import path, include

from . import views

app_name = 'pages'

urlpatterns = [
    path('', views.list, name = 'list'),
    path('create', views.create, name = 'create'),
    path('settings', views.settings, name = 'settings'),
    path('edit/<int:page_id>', views.edit, name = 'edit'),
    path('delete/<int:page_id>', views.delete, name = 'delete'),
    path('<int:page_id>/', views.detail, name = 'detail'),
]