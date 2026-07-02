# Corrigé formateur - TP Wireshark

> ⚠️ ne pas regarder avant d'avoir essayer


## Exercice 1 - HTTP

**1.1** Filtre attendu : **`http`** pour ne garder que les
requêtes. Le paquet clé est **`POST /login`**.

**1.2** Oui. Le mot de passe est **`MonMotDePasseEstSecurise_1234`**, visible en
clair dans le corps de la requête `POST /login` :
`username=apprenti&password=MonMotDePasseEstSecurise_1234`
Via **Follow → HTTP Stream**, tout le formulaire apparaît.
(La page d'accueil masque volontairement le mot de passe : c'est à l'apprenti
de le retrouver dans Wireshark et de l'écrire.)

**1.3** N'importe qui sur le même réseau capable de capturer le trafic :
- sur un réseau filaire à hub / port miroir,
- sur un Wi-Fi (surtout ouvert),
- un routeur/serveur mandataire compromis sur le trajet.


## Exercice 2 - HTTPS

**2.1** Filtre attendu : **`tls`**.

**2.2** Non. Après le handshake TLS, tout le contenu applicatif est chiffré.
`Follow → TLS Stream` ne montre que des octets illisibles (Application
Data). Le mot de passe n'apparaît nulle part.

**2.3** L'avertissement vient du **certificat auto-signé** : il n'est signé
par aucune **autorité de certification (CA)** reconnue par le navigateur. Le
chiffrement fonctionne quand même, mais rien ne prouve l'**identité** du
serveur. Une CA (Let's Encrypt, DigiCert, etc.) résout justement ce
problème.


## Exercice 3 - SMB

Filtre attendu pour tout l'exercice : **`smb2`**.

**3.1** Contenu lisible dans la trame `Read Response` du partage `public` :
**`FLAG{smb_en_clair_c_est_dangereux}`**.
Le partage a `smb encrypt = off` → les données transitent en clair.

**3.2** Sur le partage `coffre`, Wireshark affiche des trames
**« Encrypted SMB3 »** (SMB2 *Transform Header*, magic `0xFD 'S' 'M' 'B'`).
Le contenu (`FLAG{smb3_chiffre_rien_a_voir}`) est **invisible**.


## Dépannage

| Symptôme | Cause probable / solution |
|----------|---------------------------|
| Rien ne s'affiche dans Wireshark | Mauvaise interface capturée. Choisir celle avec du trafic (graphe qui bouge). |
| `POST /login` introuvable | Filtre `http` actif ? Bien cliquer « Se connecter ». |
| Port 445 déjà utilisé | Sous Windows/macOS, le partage de fichiers natif occupe 445. Le désactiver, ou lancer le serveur sur une machine Linux dédiée. |
| Connexion SMB refusée | Vérifier IP/pare-feu ; identifiants `apprenti`/`Qwertz_1234`. |
| Warning certificat bloquant (HSTS) | Utiliser une fenêtre de navigation privée ou un autre navigateur. |
| Le `coffre` se lit quand même | Normal côté client : SMB3 chiffre de façon transparente. Ce qui compte, c'est que **sur le réseau** (Wireshark) le contenu est chiffré. |
| macOS : le Finder refuse `smb://localhost` ou l'IP locale | Protection loopback : macOS interdit de monter en SMB une machine sur elle-même. N'arrive **que** si serveur et client sont le même Mac (test local). Contournement : Terminal → `mount_smbfs -N "//apprenti:Qwertz_1234@127.0.0.1/public" /tmp/smbtest`. Sans objet le jour J (machines distinctes). |


## Nettoyage

```bash
docker compose down               # arrête tout
docker compose down --rmi local   # + supprime les images construites
```
