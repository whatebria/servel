# Generated by Django 5.2.1 on 2025-05-21 23:46

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='profile',
            name='perfile_picture',
            field=models.ImageField(default='default.avif', upload_to=''),
            preserve_default=False,
        ),
    ]
