# Generated by Django 2.1.3 on 2019-01-22 08:57

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('pages', '0003_page_iscached'),
    ]

    operations = [
        migrations.RenameField(
            model_name='page',
            old_name='isCached',
            new_name='is_cached',
        ),
    ]
