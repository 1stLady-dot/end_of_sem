from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

path = Path(__file__).resolve().parents[1] / 'assets' / 'icons' / 'icon.png'
path.parent.mkdir(parents=True, exist_ok=True)

size = 1024
bg = (183, 28, 28)
img = Image.new('RGB', (size, size), bg)
draw = ImageDraw.Draw(img)

w = size
cx = w // 2
cy = w // 2 - 80
outer_w = 520
outer_h = 620
r = 160
left = cx - outer_w // 2
right = cx + outer_w // 2
upper = cy - outer_h // 2
lower = cy + outer_h // 2

draw.rounded_rectangle([(left, upper), (right, lower)], radius=r, fill='white')
inner_pad = 120
draw.rounded_rectangle(
    [(left + inner_pad, upper + inner_pad), (right - inner_pad, lower - inner_pad)],
    radius=r - 40,
    fill=bg,
)

line_h = 120
draw.rectangle([left, cy - line_h // 2, right, cy + line_h // 2], fill=bg)

try:
    font = ImageFont.truetype('arial.ttf', 92)
except Exception:
    font = ImageFont.load_default()

text = 'CAMPUSGUARD'
try:
    text_w, text_h = font.getsize(text)
except Exception:
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
draw.text(((w - text_w) // 2, cy + outer_h // 2 + 60), text, fill='white', font=font)

img.save(path, format='PNG')
print('saved', path)
