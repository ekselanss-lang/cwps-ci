import http.server, socketserver, sys
BULUNAN = set("admin administrator login panel cpanel api v1 v2 test dev staging demo backup backups uploads files docs config settings env robots.txt sitemap.xml user users account accounts dashboard manage manager images css js static media data db database phpmyadmin pma wp-admin wp-login.php swagger openapi graphql health status metrics version shell cmd info.php phpinfo.php".split())
class H(http.server.BaseHTTPRequestHandler):
    def _y(self, kod):
        self.send_response(kod)
        self.send_header("Content-Type","text/html; charset=utf-8")
        self.send_header("Server","CWPS-TEST/1.0")
        self.send_header("Set-Cookie","sid=abc; Path=/")
        self.end_headers()
        self.wfile.write(b"<html><body>CWPS-TEST-MARKER<form action=/login method=post><input name=username><input name=password type=password><input name=file type=file></form></body></html>")
    def do_GET(self):
        yol = self.path.split("?")[0].strip("/").split("/")[0].lower()
        self._y(200 if (yol in BULUNAN or yol == "") else 404)
    def do_POST(self): self._y(200)
    def log_message(self, *a): pass
socketserver.TCPServer.allow_reuse_address = True
port = int(sys.argv[1]) if len(sys.argv) > 1 else 80
socketserver.TCPServer(("127.0.0.1", port), H).serve_forever()
