import os
import django
from django.core.management.base import BaseCommand

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mental_health_backend.settings')
django.setup()

from auth_api.models import AffirmationCategory, GenericAffirmation, AffirmationTemplate
from django.db import transaction

class Command(BaseCommand):
    help = 'Seed affirmations data with DEBUG'

    def handle(self, *args, **options):
        self.stdout.write('🔍 DEBUGGING AFFIRMATIONS SEED...')
        
        try:
            with transaction.atomic():
                # Clear existing data
                deleted_cats = AffirmationCategory.objects.count()
                deleted_affs = GenericAffirmation.objects.count()
                AffirmationCategory.objects.all().delete()
                GenericAffirmation.objects.all().delete()
                self.stdout.write(f'🗑️  Cleared {deleted_cats} categories, {deleted_affs} affirmations')
                
                # 1. CREATE CATEGORIES FIRST
                categories = [
                    {'name': 'Confidence', 'description': 'Build self-confidence'},
                    {'name': 'Calmness', 'description': 'Find inner peace'},
                    {'name': 'Gratitude', 'description': 'Practice thankfulness'},
                    {'name': 'Resilience', 'description': 'Overcome challenges'},
                    {'name': 'Self-Love', 'description': 'Cultivate self-love'},
                    {'name': 'Abundance', 'description': 'Attract prosperity'},
                ]
                
                created_cats = []
                for cat_data in categories:
                    category, created = AffirmationCategory.objects.get_or_create(
                        name=cat_data['name'],
                        defaults={'description': cat_data['description']}
                    )
                    if created:
                        created_cats.append(category.name)
                        self.stdout.write(self.style.SUCCESS(f'✅ Created category: {category.name} (ID: {category.id})'))
                    else:
                        self.stdout.write(self.style.WARNING(f'⚠️  Category exists: {category.name} (ID: {category.id})'))
                
                self.stdout.write(self.style.SUCCESS(f'📊 Total categories: {AffirmationCategory.objects.count()}'))
                
                # 2. CREATE AFFIRMATIONS - ONE BY ONE WITH DEBUG
                affirmations_data = {
                    'Confidence': [
                        'I am confident in my abilities and trust myself completely.',
                        'I believe in myself and my capacity to succeed.',
                        'Every challenge I face helps me grow stronger and wiser.',
                        'I am worthy of success and respect.',
                        'I speak my truth with confidence and clarity.',
                    ],
                    'Calmness': [
                        'I am at peace with myself and the world around me.',
                        'I breathe deeply and release all tension.',
                        'My mind is calm and my heart is peaceful.',
                        'I find serenity in every moment.',
                        'I let go of stress and embrace tranquility.',
                    ],
                    'Gratitude': [
                        'I am grateful for the abundance in my life.',
                        'Every day I wake up thankful and blessed.',
                        'I appreciate all the good things in my life.',
                        'Gratitude fills my heart and mind.',
                        'I am thankful for the lessons I learn every day.',
                    ],
                    'Resilience': [
                        'I am stronger than my struggles and challenges.',
                        'Every setback is a setup for a comeback.',
                        'I rise above difficulties with grace and strength.',
                        'My resilience grows with every obstacle I overcome.',
                        'I am unbreakable and unstoppable.',
                    ],
                    'Self-Love': [
                        'I love and accept myself completely as I am.',
                        'I am worthy of love and respect.',
                        'I treat myself with kindness and compassion.',
                        'I am enough just as I am.',
                        'Self-love is my foundation and strength.',
                    ],
                    'Abundance': [
                        'I am a money magnet and attract abundance easily.',
                        'Wealth flows to me from expected and unexpected sources.',
                        'I am open to receiving all the universe has to offer.',
                        'Money comes to me quickly and effortlessly.',
                        'I am grateful for the abundance already in my life.',
                    ]
                }
                
                created_affirmations = 0
                for category_name, texts in affirmations_data.items():
                    try:
                        category = AffirmationCategory.objects.get(name=category_name)
                        self.stdout.write(f'🔗 Linking to category: {category_name} (ID: {category.id})')
                        
                        for i, text in enumerate(texts, 1):
                            affirmation, created = GenericAffirmation.objects.get_or_create(
                                text=text.strip(),
                                category=category,
                                defaults={
                                    'is_active': True,
                                    'author': f'Mental Wellness Team'
                                }
                            )
                            if created:
                                created_affirmations += 1
                                self.stdout.write(self.style.SUCCESS(f'  ✅ Aff {i}: "{text[:30]}..." (ID: {affirmation.id})'))
                            else:
                                self.stdout.write(f'  ⚠️  Aff {i} already exists')
                                
                    except AffirmationCategory.DoesNotExist:
                        self.stdout.write(self.style.ERROR(f'❌ Category {category_name} NOT FOUND!'))
                        continue
                
                # FINAL COUNT
                total_cats = AffirmationCategory.objects.count()
                total_affs = GenericAffirmation.objects.count()
                self.stdout.write(self.style.SUCCESS(f'🎉 FINAL: {total_cats} categories, {total_affs} affirmations'))
                
                if total_affs == 0:
                    self.stdout.write(self.style.ERROR('🚨 NO AFFIRMATIONS CREATED! Check models.py'))
                
        except Exception as e:
            self.stdout.write(self.style.ERROR(f'💥 SEED FAILED: {str(e)}'))
            import traceback
            self.stdout.write(traceback.format_exc())