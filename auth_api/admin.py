from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import User
from .models import (
    UserProfile, Guardian, Category, MeditationSession, YogaSession,
    UserPreferences, BackgroundMusic, CalmingSession, GroundingSession,
    PanicSession, StressBusterSession, MoodLog, AffirmationCategory,
    GenericAffirmation, CustomAffirmation, AffirmationTemplate, MusicCategory, MusicTrack, MusicSession, CBTTopic, CBTSession,
    Disorder, Article, CopingMethod, RoadmapStep,  # ✅ ADDED Resources Hub models
    TherapySession, ReflectionQuestion, TherapyRecord, TherapyRecordAnswer,
    MusicTherapySession, DrawingTherapySession # ✅ PROXY MODELS
)
# ✅ UNREGISTER DEFAULT USER ADMIN
try:
    admin.site.unregister(User)
except admin.sites.NotRegistered:
    pass

# ---------------------------
# USER INLINES
# ---------------------------
class UserProfileInline(admin.StackedInline):
    model = UserProfile
    can_delete = False
    fields = ['name', 'age', 'phone_number', 'email', 'gender', 'medical_history']

class GuardianInline(admin.TabularInline):
    model = Guardian
    extra = 1
    fields = ['name', 'relationship', 'phone_number', 'email']

# ---------------------------
# CUSTOM USER ADMIN
# ---------------------------
@admin.register(User)
class CustomUserAdmin(UserAdmin):
    inlines = [UserProfileInline, GuardianInline]
    list_display = ['username', 'email', 'is_active', 'date_joined']
    search_fields = ['username', 'email']

# ---------------------------
# MODELS WITHOUT CREATED_AT IN LIST_DISPLAY
# ---------------------------
@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['name', 'user', 'age', 'phone_number', 'email', 'gender']
    search_fields = ['name', 'email', 'phone_number']

@admin.register(Guardian)
class GuardianAdmin(admin.ModelAdmin):
    list_display = ['name', 'user', 'relationship', 'phone_number']
    search_fields = ['name', 'phone_number', 'email']

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'emoji']  # ✅ NO created_at
    search_fields = ['name']

@admin.register(MeditationSession)
class MeditationSessionAdmin(admin.ModelAdmin):
    list_display = ['title', 'duration', 'category', 'emoji']  # ✅ NO created_at
    fields = ['title', 'description', 'duration', 'audio_file', 'category', 'emoji', 'guidance_text', 'image']
    search_fields = ['title', 'description']
    list_filter = ['category']

@admin.register(YogaSession)
class YogaSessionAdmin(admin.ModelAdmin):
    list_display = ['title', 'duration', 'type', 'emoji', 'channel_name']  # ✅ NO created_at
    fields = ['title', 'description', 'duration', 'audio_file', 'type', 'emoji', 'video_url', 'channel_name', 'image']
    search_fields = ['title', 'description']
    list_filter = ['type']

@admin.register(UserPreferences)
class UserPreferencesAdmin(admin.ModelAdmin):
    list_display = ['user', 'meditation_music_on']  # ✅ NO created_at
    search_fields = ['user__username']

@admin.register(BackgroundMusic)
class BackgroundMusicAdmin(admin.ModelAdmin):
    list_display = ['title', 'emoji']  # ✅ NO created_at
    search_fields = ['title']

@admin.register(CalmingSession)
class CalmingSessionAdmin(admin.ModelAdmin):
    list_display = ['user', 'actions', 'end_time']
    search_fields = ['user__username', 'actions']

@admin.register(GroundingSession)
class GroundingSessionAdmin(admin.ModelAdmin):
    list_display = ['user', 'end_time']
    search_fields = ['user__username']

@admin.register(PanicSession)
class PanicSessionAdmin(admin.ModelAdmin):
    list_display = ['user', 'end_time']
    search_fields = ['user__username']

@admin.register(StressBusterSession)
class StressBusterSessionAdmin(admin.ModelAdmin):
    list_display = ['user', 'session_type', 'duration', 'end_time']
    search_fields = ['user__username', 'session_type']

@admin.register(MoodLog)
class MoodLogAdmin(admin.ModelAdmin):
    list_display = ['user', 'mood_emoji', 'mood_label', 'tag', 'date_time']
    search_fields = ['user__username', 'mood_label']
    list_filter = ['mood_label', 'tag']

# ---------------------------
# AFFIRMATIONS (ONLY WHAT EXISTS)
# ---------------------------
class GenericAffirmationInline(admin.TabularInline):
    model = GenericAffirmation
    extra = 3
    fields = ['text', 'is_active']

@admin.register(AffirmationCategory)
class AffirmationCategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'icon']  # ✅ NO created_at
    search_fields = ['name', 'description']
    inlines = [GenericAffirmationInline]

@admin.register(GenericAffirmation)
class GenericAffirmationAdmin(admin.ModelAdmin):
    list_display = ['text_preview', 'category', 'is_active']
    list_filter = ['category', 'is_active']
    search_fields = ['text']
    
    def text_preview(self, obj):
        return obj.text[:50] + "..." if len(obj.text) > 50 else obj.text

@admin.register(CustomAffirmation)
class CustomAffirmationAdmin(admin.ModelAdmin):
    list_display = ['user', 'focus_area', 'created_at']
    list_filter = ['focus_area', 'user']
    search_fields = ['affirmation_text', 'user__username']

@admin.register(AffirmationTemplate)
class AffirmationTemplateAdmin(admin.ModelAdmin):
    list_display = ['template_preview', 'focus_areas']
    search_fields = ['template']
    
    def template_preview(self, obj):
        return obj.template[:50] + "..."

# MUSIC ADMIN (NEW)
class MusicTrackInline(admin.TabularInline):
    model = MusicTrack
    extra = 2
    fields = ['title', 'audio_file', 'duration', 'emoji']  # Fixed: 'audio_file' instead of 'audio_url'

@admin.register(MusicCategory)
class MusicCategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'emoji', 'color', 'created_at']
    search_fields = ['name']
    inlines = [MusicTrackInline]
    list_filter = ['created_at']

@admin.register(MusicTrack)
class MusicTrackAdmin(admin.ModelAdmin):
    list_display = ['title', 'category', 'duration', 'audio_file']  # Fixed: 'audio_file' instead of 'audio_url'
    list_filter = ['category']
    search_fields = ['title', 'audio_file']  # Fixed search too

@admin.register(MusicSession)
class MusicSessionAdmin(admin.ModelAdmin):
    list_display = ['user', 'category', 'mood_change', 'current_emotion', 'session_duration', 'created_at']
    list_filter = ['mood_change', 'current_emotion', 'category']
    search_fields = ['user__username']

# CBT ADMIN (NEW)
@admin.register(CBTTopic)
class CBTTopicAdmin(admin.ModelAdmin):
    list_display = ['title', 'emoji', 'color', 'created_at']
    search_fields = ['title']

@admin.register(CBTSession)
class CBTSessionAdmin(admin.ModelAdmin):
    list_display = ['user', 'topic', 'created_at']
    list_filter = ['topic']
    search_fields = ['user__username', 'balanced_thought']
# Resources Hub (NEW)
class ArticleInline(admin.TabularInline):
    model = Article
    extra = 2
    fields = ['title', 'content', 'url']

class CopingMethodInline(admin.TabularInline):
    model = CopingMethod
    extra = 2
    fields = ['title', 'instructions']

class RoadmapStepInline(admin.TabularInline):
    model = RoadmapStep
    extra = 2
    fields = ['title', 'description', 'image', 'order']

@admin.register(Disorder)
class DisorderAdmin(admin.ModelAdmin):
    list_display = ['name', 'emoji', 'created_at']
    search_fields = ['name', 'summary']
    inlines = [ArticleInline, CopingMethodInline, RoadmapStepInline]

@admin.register(Article)
class ArticleAdmin(admin.ModelAdmin):
    list_display = ['title', 'disorder', 'created_at']
    list_filter = ['disorder']
    search_fields = ['title', 'content']

@admin.register(CopingMethod)
class CopingMethodAdmin(admin.ModelAdmin):
    list_display = ['title', 'disorder', 'created_at']
    list_filter = ['disorder']
    search_fields = ['title', 'instructions']

@admin.register(RoadmapStep)
class RoadmapStepAdmin(admin.ModelAdmin):
    list_display = ['title', 'disorder', 'order', 'created_at']
    list_filter = ['disorder']
    search_fields = ['title', 'description']

# THERAPY ADMIN (NEW)
from .models import TherapySession, ReflectionQuestion, TherapyRecord, TherapyRecordAnswer

class ReflectionQuestionInline(admin.StackedInline):
    model = ReflectionQuestion
    extra = 1
    fields = ['question_text', 'question_type', 'options', 'order']

@admin.register(MusicTherapySession)
class MusicTherapySessionAdmin(admin.ModelAdmin):
    list_display = ['title', 'duration', 'created_at']
    search_fields = ['title']
    # Exclude drawing fields
    fields = ['title', 'audio_file', 'duration', 'image', 'created_at']
    readonly_fields = ['created_at']
    inlines = [ReflectionQuestionInline]
    
    def save_model(self, request, obj, form, change):
        obj.therapy_type = 'Music'
        super().save_model(request, obj, form, change)
        
    def get_queryset(self, request):
        return super().get_queryset(request).filter(therapy_type='Music')

@admin.register(DrawingTherapySession)
class DrawingTherapySessionAdmin(admin.ModelAdmin):
    list_display = ['title', 'created_at']
    search_fields = ['title']
    # Exclude music fields
    fields = ['title', 'prompt_text', 'image', 'created_at']
    readonly_fields = ['created_at']
    inlines = [ReflectionQuestionInline]

    def save_model(self, request, obj, form, change):
        obj.therapy_type = 'Drawing'
        super().save_model(request, obj, form, change)

    def get_queryset(self, request):
        return super().get_queryset(request).filter(therapy_type='Drawing')


class TherapyRecordAnswerInline(admin.TabularInline):
    model = TherapyRecordAnswer
    extra = 0
    readonly_fields = ['question', 'answer_text']
    can_delete = False

@admin.register(TherapyRecord)
class TherapyRecordAdmin(admin.ModelAdmin):
    list_display = ['user', 'session', 'mood_before', 'mood_after', 'created_at']
    list_filter = ['session__therapy_type', 'created_at']
    search_fields = ['user__username', 'session__title']
    inlines = [TherapyRecordAnswerInline]
    readonly_fields = ['user', 'session', 'mood_before', 'mood_after', 'drawing_file', 'reflection_notes', 'created_at']

@admin.register(TherapyRecordAnswer)
class TherapyRecordAnswerAdmin(admin.ModelAdmin):
    list_display = ['record', 'question', 'answer_text']
