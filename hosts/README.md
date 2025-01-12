## Writing hosts.ini files

```ini
; specify groups with a `[]`
; groups can contain ip address or fqdn of the server
[app]
192.168.1.65
192.168.1.66
app.example.com

[db]
192.168.1.67

; groups can also contain other groups
; here, the group multi has two sub groups 'app' and 'db'
[multi:children]
app
db

; groups can have specific variables
[app:vars]
user=ubuntu-base

[multi:vars]
var1=ubuntu
```
