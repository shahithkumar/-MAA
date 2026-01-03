from django.core.mail import send_mail
from django.conf import settings
from django.utils import timezone
from auth_api.models import Guardian, UserProfile

def send_crisis_email(user, user_message):
    """
    Sends an immediate crisis alert email to the user's guardian.
    """
    try:
        print(f"🚨 CRISIS DETECTED for user: {user.username}")
        
        # 1. Fetch Data
        profile = UserProfile.objects.get(user=user)
        guardian = Guardian.objects.filter(user=user).first()
        
        if not guardian:
            print("❌ No guardian found regarding crisis alert.")
            return

        print(f"🛡️ Sending Alert to Guardian: {guardian.name} ({guardian.email})")

        # 2. Construct Email
        subject = f"⚠️ CRITICAL ALERT: {profile.name} may be in danger"
        
        html_message = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                .container {{
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    max-width: 600px;
                    margin: 0 auto;
                    border: 3px solid #d93025;
                    border-radius: 12px;
                    overflow: hidden;
                    background-color: #ffffff;
                }}
                .header {{
                    background-color: #d93025;
                    color: white;
                    padding: 24px;
                    text-align: center;
                }}
                .content {{
                    padding: 30px;
                    color: #333333;
                    line-height: 1.6;
                }}
                .alert-box {{
                    background-color: #fce8e6;
                    border-left: 6px solid #d93025;
                    padding: 20px;
                    margin: 20px 0;
                    border-radius: 4px;
                }}
                .message-box {{
                    background-color: #f1f3f4;
                    padding: 15px;
                    border-radius: 8px;
                    font-style: italic;
                    margin: 10px 0;
                    border: 1px solid #dadce0;
                }}
                .footer {{
                    background-color: #f8f9fa;
                    padding: 15px;
                    text-align: center;
                    font-size: 12px;
                    color: #777777;
                    border-top: 1px solid #eaeaea;
                }}
                .button {{
                    display: inline-block;
                    padding: 14px 28px;
                    background-color: #d93025;
                    color: white !important;
                    text-decoration: none;
                    border-radius: 8px;
                    font-weight: bold;
                    margin-top: 20px;
                    text-align: center;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1 style="margin:0; font-size: 24px;">⚠️ CRITICAL SAFETY ALERT</h1>
                </div>
                <div class="content">
                    <p>Dear <strong>{guardian.name}</strong>,</p>
                    <p>Our AI system has detected highly concerning language from <strong>{profile.name}</strong> indicating they may be at immediate risk of harm or in severe distress.</p>
                    
                    <div class="alert-box">
                        <h3 style="color:#d93025; margin-top:0;">Risk Level: CRITICAL</h3>
                        <p><strong>Trigger Message:</strong></p>
                        <div class="message-box">"{user_message}"</div>
                    </div>

                    <p><strong>Please take immediate action:</strong></p>
                    <ol>
                        <li>Call them immediately.</li>
                        <li>If they are unresponsive or in danger, contact local emergency services.</li>
                    </ol>
                    
                    <p><strong>User Details:</strong><br>
                    📞 Phone: <a href="tel:{profile.phone_number}" style="color:#1a73e8; font-weight:bold;">{profile.phone_number}</a><br>
                    🕒 Time: {timezone.now().strftime('%Y-%m-%d %H:%M:%S')}</p>

                    <center>
                        <a href="tel:{profile.phone_number}" class="button">CALL {profile.name.upper()} NOW</a>
                    </center>
                </div>
                <div class="footer">
                    Sent via MAA Mental Health App Safety Protocol.<br>
                    This is an automated message triggered by specific safety keywords.
                </div>
            </div>
        </body>
        </html>
        """
        
        plain_message = (
            f"⚠️ CRITICAL SAFETY ALERT\n\n"
            f"Dear {guardian.name},\n"
            f"{profile.name} has sent a message indicating potential self-harm or severe distress.\n\n"
            f"Message: \"{user_message}\"\n\n"
            f"Please contact them immediately: {profile.phone_number}\n"
            f"Time: {timezone.now().strftime('%Y-%m-%d %H:%M:%S')}"
        )

        # 3. Send
        send_mail(
            subject,
            plain_message,
            settings.EMAIL_HOST_USER,
            [guardian.email],
            fail_silently=False,
            html_message=html_message
        )
        print("✅ Crisis Email SENT Successfully.")

    except Exception as e:
        print(f"❌ FAILED to send crisis email: {e}")
