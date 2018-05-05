#!/usr/bin/env python2

ga_tracking_code = '''
'''.strip()

with open('index.html', 'r') as f: content = f.read()
content = content.replace("<head>", "<head>\n" + ga_tracking_code)
with open('index.html', 'w') as f: f.write(content)
