import os
import re

d = r'c:\xampp\htdocs\Asfor\asfor_app\lib\screens'
for f in os.listdir(d):
    if f.endswith('.dart') and f != 'main_screen.dart' and f != 'dashboard_screen.dart':
        p = os.path.join(d, f)
        with open(p, 'r', encoding='utf-8') as file:
            c = file.read()
        c = c.replace("import 'main_screen.dart' show mainScaffoldKey;", "import 'main_screen.dart' show mainScaffoldKey, buildMenuButton;")
        c = re.sub(r'leading:\s*IconButton\(\s*icon:\s*const\s*Icon\(Icons\.menu_rounded\),?\s*onPressed:\s*\(\)\s*=>\s*mainScaffoldKey\.currentState\?\.openDrawer\(\),\s*\),', 'leading: buildMenuButton(context),', c)
        with open(p, 'w', encoding='utf-8') as file:
            file.write(c)
