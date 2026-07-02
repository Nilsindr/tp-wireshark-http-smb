"""
Mini site de demo pour le TP Wireshark.
Un simple formulaire de login. Le but pedagogique :
 - En HTTP, le couple identifiant/mot de passe part EN CLAIR dans le
   corps de la requete POST -> visible dans Wireshark (Follow TCP Stream).
 - En HTTPS, exactement la meme requete, mais chiffree par TLS.

Aucune base de donnees : on affiche juste ce qu'on a recu, ce qui rend
la demo tres parlante ("regarde, le serveur a bien lu ton mot de passe").
"""
from flask import Flask, request, render_template

app = Flask(__name__)


@app.route("/", methods=["GET"])
def index():
    # Le navigateur envoie X-Forwarded-Proto via nginx : on s'en sert
    # juste pour afficher un bandeau HTTP / HTTPS a l'ecran.
    proto = request.headers.get("X-Forwarded-Proto", "http")
    return render_template("login.html", proto=proto)


@app.route("/login", methods=["POST"])
def login():
    username = request.form.get("username", "")
    password = request.form.get("password", "")
    proto = request.headers.get("X-Forwarded-Proto", "http")

    # On loggue cote serveur (visible avec `docker compose logs web`).
    print(f"[LOGIN via {proto.upper()}] username={username!r} password={password!r}",
          flush=True)

    return render_template("welcome.html",
                           username=username,
                           password=password,
                           proto=proto)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
