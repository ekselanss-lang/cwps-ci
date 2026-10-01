#!/usr/bin/env python3
# CYBERWOLF SECURITY - arayuz statik kontrol (gercek Windows/UI testinden onceki hizli kapi)
# dis.cpp icindeki gomulu HTML/JS'i cikarir; calismayan buton/sekme/JS hatasi varsa FAIL verir.
import re, sys, subprocess, os, tempfile, json

D = "dis.cpp"
if not os.path.exists(D):
    print("FAIL  dis.cpp yok"); sys.exit(1)
src = open(D, encoding="utf-8", errors="replace").read()

mm = re.search(r'GOMULU_UI\s*=\s*R"([A-Za-z]*)\(', src)
if not mm:
    print("FAIL  gomulu arayuz (GOMULU_UI) bulunamadi"); sys.exit(1)
delim = mm.group(1)
bitis = src.find(')' + delim + '"', mm.end())
if bitis < 0:
    print("FAIL  arayuz bitisi bulunamadi"); sys.exit(1)
ui = src[mm.end():bitis]
print("arayuz uzunlugu: %d karakter" % len(ui))

hata, uyari, ok = [], [], 0

# 1) TUM onclick fonksiyonlari tanimli mi?
onclick = set(re.findall(r'onclick="([A-Za-z_][A-Za-z0-9_]*)\(', ui))
# JS icinde tanimli fonksiyonlar + atamalar
tanimli = set(re.findall(r'function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(', ui))
tanimli |= set(re.findall(r'(?:window|this)\.([A-Za-z_][A-Za-z0-9_]*)\s*=', ui))
tanimli |= set(re.findall(r'const\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?:async\s*)?(?:function|\()', ui))
# HTML attribute handlerlari (onchange, oninput, onkeydown ...)
for attr in ["onchange","oninput","onkeydown","onkeyup","onsubmit","onclick"]:
    onclick |= set(re.findall(attr + r'="([A-Za-z_][A-Za-z0-9_]*)\(', ui))
eksik = sorted(f for f in onclick if f not in tanimli)
if eksik:
    hata.append("TANIMSIZ FONKSIYON (buton cagiriyor ama fonksiyon yok): " + ", ".join(eksik))
else:
    ok += 1; print("PASS  tum onclick/onchange fonksiyonlari tanimli (%d fonksiyon)" % len(onclick))

# 2) data-s sekmeleri icin sayfa var mi?
sekmeler = set(re.findall(r'data-s="([a-z_]+)"', ui))
sayfalar = set(re.findall(r'id="s-([a-z_]+)"', ui))
eksik_s = sorted(s for s in sekmeler if s not in sayfalar)
if eksik_s:
    hata.append("SAYFASI OLMAYAN SEKME (tiklayinca bos acilir): " + ", ".join(eksik_s))
else:
    ok += 1; print("PASS  her sekme icin sayfa var (%d sekme: %s)" % (len(sekmeler), ",".join(sorted(sekmeler))))

# 3) getElementById referanslari HTML'de var mi?
idler = set(re.findall(r'id="([A-Za-z0-9_\-]+)"', ui))
ref = set(re.findall(r'getElementById\("([A-Za-z0-9_\-]+)"\)', ui))
# JS icinde olusturulan id'ler (innerHTML icinde id='x' veya id=\"x\")
js_uzanti = set(re.findall(r"id=\\?['\"]([A-Za-z0-9_\-]+)", ui))
eksik_id = sorted(r for r in ref if r not in idler and r not in js_uzanti)
if eksik_id:
    uyari.append("JS'in aradigi ama hicbir yerde olmayan id: " + ", ".join(eksik_id))
else:
    ok += 1; print("PASS  getElementById referanslarinin hepsi mevcut (%d referans)" % len(ref))

# 4) Ayni id birden fazla tanimli mi? (bozuk arayuz)
tekrar = sorted(i for i in idler if len(re.findall(r'id="%s"' % re.escape(i), ui)) > 1)
if tekrar:
    hata.append("AYNI ID TEKRAR (cakisma): " + ", ".join(tekrar[:12]))
else:
    ok += 1; print("PASS  tekrarlanan id yok (%d benzersiz id)" % len(idler))

# 5) JS sozdizimi (node --check)
parcalar = re.findall(r'<script[^>]*>(.*?)</script>', ui, re.S)
if parcalar:
    toplam = "\n;\n".join(parcalar)
    tf = tempfile.NamedTemporaryFile("w", suffix=".js", delete=False, encoding="utf-8")
    tf.write(toplam); tf.close()
    r = subprocess.run(["node", "--check", tf.name], capture_output=True, text=True)
    if r.returncode != 0:
        hata.append("JAVASCRIPT SOZDIZIMI HATASI: " + (r.stderr.strip().splitlines()[0] if r.stderr.strip() else "bilinmiyor"))
    else:
        ok += 1; print("PASS  JavaScript sozdizimi temiz (%d script blogu, %d karakter)" % (len(parcalar), len(toplam)))
    os.unlink(tf.name)
else:
    uyari.append("hic <script> blogu bulunamadi")

# 6) Motor uc cagrilari: UI'nin cagirdigi /api uclari motor'da var mi?
motor = open("motor.cpp", encoding="utf-8", errors="replace").read()
uclar = set(re.findall(r'iste\("([a-z0-9_]+)[^"]*"', ui)) | set(re.findall(r'iste\(\s*"([a-z0-9_]+)', ui))
eksik_uc = sorted(u for u in uclar if ('/api/' + u) not in motor and ('"' + u) not in motor)
if eksik_uc:
    hata.append("MOTORDA KARSILIGI OLMAYAN UC: " + ", ".join(eksik_uc))
else:
    ok += 1; print("PASS  arayuzun cagirdigi %d motor ucu tanimli" % len(uclar))

print("\n---- SONUC ----")
for w in uyari: print("UYARI " + w)
for h in hata: print("HATA  " + h)
print("PASS=%d  HATA=%d  UYARI=%d" % (ok, len(hata), len(uyari)))
sys.exit(1 if hata else 0)
