# TP Wireshark - HTTP/HTTPS et SMB clair vs chiffré

> **Labo École - EPFL** · Exercice pratique
>
> Objectif : voir **en vrai**, avec Wireshark, la différence entre un
> protocole en clair et un protocole chiffré. On capture son propre trafic
> pendant qu'on se connecte à un petit serveur monté pour l'occasion.


## 🎯 Ce que tu vas apprendre

1. **HTTP** : un mot de passe saisi dans un site part **en clair** sur le
   réseau. On le retrouve dans Wireshark en quelques clics.
2. **HTTPS** : exactement le même site, mais tout est chiffré par TLS. On
   cherche mais on ne trouve rien.
3. **SMB (partage de fichiers)** : le contenu d'un fichier transite **en
   clair** sur un partage non chiffré, mais devient illisible sur un partage
   **SMB3 chiffré**.


## 🧰 Prérequis

- **Docker** + **Docker Compose** → https://docs.docker.com/get-docker/
- **Wireshark** installé sur ta machine → https://www.wireshark.org/download.html
- Un navigateur web
- Un explorateur de fichiers

Deux façons de faire tourner le TP :

- **Chacun sur sa machine** : tu lances le serveur ET tu captures sur le même
  ordinateur. Tu utilises alors l'adresse `localhost`.
- **Un seul ordinateur pour tout le monde** : une machine héberge le serveur,
  et chaque participant s'y connecte via son **adresse IP** (`<IP_SERVEUR>`).
  Il suffit d'être sur le même réseau.


## 🚀 Démarrage du serveur

Sur l'ordinateur qui fera office de serveur, lance ces 3 commandes :

```bash
git clone <url-du-repo>                # récupérer le projet depuis GitHub
cd Wireshark                           # entrer dans le dossier du projet
docker compose up -d --build           # construire et lancer le projet avec Docker
```

Trois services démarrent :

| Service | Port | Rôle |
|---------|------|------|
| nginx   | 80   | Site de login **HTTP** (en clair) |
| nginx   | 443  | Site de login **HTTPS** (chiffré, certif auto-signé) |
| smb     | 445  | Partages `public` (clair) et `coffre` (SMB3 chiffré) |

Pour tout arrêter proprement : `docker compose down`

> **Trouver l'adresse IP du serveur** (utile en mode « un seul serveur ») :
> `ip a` (Linux), `ipconfig` (Windows) ou Réglages → Réseau (macOS).


## 🔎 Exercice 1 - HTTP : voler un mot de passe en clair

1. Ouvre **Wireshark**, double-clique sur ton interface réseau pour démarrer la
   capture (⚠️ attention à choisir la bonne - si tu utilises `localhost`, c'est
   l'interface *loopback*).
2. Dans le champ de filtre (en haut), applique un filtre pour n'afficher que le
   trafic qui t'intéresse.
3. Ouvre ton navigateur sur **`http://localhost/`** (ou **`http://<IP_SERVEUR>/`**
   si le serveur tourne sur un autre ordinateur).
4. Laisse l'identifiant et le mot de passe pré-remplis, clique **Se connecter**.
5. Reviens dans Wireshark et essaie maintenant de retrouver les identifiants.

**➡️ Question 1.1 :** Quel est le filtre que tu as utilisé ?

**➡️ Question 1.2 :** Retrouves-tu le mot de passe ?

**➡️ Question 1.3 :** À ton avis, qui d'autre sur le réseau aurait pu le voir ?


## 🔒 Exercice 2 - HTTPS : le même site, mais chiffré

1. Garde Wireshark en capture. *Indice : change de filtre.*
2. Va sur **`https://localhost/`** (ou **`https://<IP_SERVEUR>/`**).
   - ⚠️ Le navigateur affiche un **avertissement de sécurité** : c'est normal,
     le certificat est *auto-signé*. Clique « Continuer quand même ».
3. Connecte-toi de nouveau (même mot de passe).
4. Dans Wireshark, essaie de retrouver le mot de passe. *Indice : clic droit sur
   une trame de la conversation → **Follow → TLS Stream**.*

**➡️ Question 2.1 :** Quel est le filtre que tu as utilisé cette fois ?

**➡️ Question 2.2 :** Arrives-tu à lire le mot de passe cette fois ? Pourquoi ?

**➡️ Question 2.3 :** Pourquoi le navigateur a-t-il affiché un avertissement,
alors que HTTPS est censé être *plus* sécurisé que HTTP ? Qu'est-ce qu'une
*autorité de certification* règle comme problème ?


## 📁 Exercice 3 - SMB : contenu de fichier clair vs chiffré

Deux partages sont disponibles, tous les deux avec le compte
**`apprenti`** / mot de passe **`Qwertz_1234`**.

### 3a - Partage `public` (NON chiffré)

1. Dans Wireshark, applique le filtre adapté au trafic SMB.
2. Ouvre le partage (remplace `<IP_SERVEUR>` par `localhost` si le serveur est
   sur ta machine) :
   - **Windows** : dans l'explorateur, tape `\\<IP_SERVEUR>\public`
   - **macOS** : Finder → `Cmd+K` → `smb://<IP_SERVEUR>/public`
   - **Linux** : `smbclient //<IP_SERVEUR>/public -U apprenti`
3. Ouvre le fichier `message_secret.txt`.
4. Dans Wireshark, retrouve la trame qui contient le contenu du fichier.
   *Indice : clic droit → **Follow → TCP Stream**.*

**➡️ Question 3.1 :** Quel est le contenu du fichier, vu directement dans
Wireshark ?

### 3b - Partage `coffre` (SMB3 chiffré)

1. Ferme la connexion précédente et garde la capture (tu peux aussi en relancer
   une nouvelle s'il y a trop d'informations à l'écran).
2. Ouvre `\\<IP_SERVEUR>\coffre` (ou `smb://localhost/coffre`) et lis son
   `message_secret.txt`.
3. Dans Wireshark, regarde les trames.

**➡️ Question 3.2 :** Qu'est-ce qui a changé ? Que voit-on à la place du contenu
du fichier ?

### ⚙️ Cas particulier : le serveur SMB tourne sur TA propre machine

Si tu héberges le serveur sur la **même** machine que celle qui teste, utilise
`localhost` / `127.0.0.1`. Selon l'OS, il y a une petite manip à faire.

#### 🍎 macOS - si le Finder (`Cmd+K`) ne fonctionne pas

macOS **refuse** de connecter le Finder en SMB à sa propre machine. Passe par le
**Terminal** :

```bash
mkdir -p /tmp/smbtest

# Partage public (en clair)
mount_smbfs -N "//apprenti:Qwertz_1234@127.0.0.1/public" /tmp/smbtest
cat /tmp/smbtest/message_secret.txt
umount /tmp/smbtest

# Partage coffre (chiffré)
mount_smbfs -N "//apprenti:Qwertz_1234@127.0.0.1/coffre" /tmp/smbtest
cat /tmp/smbtest/message_secret.txt
umount /tmp/smbtest
```

> Le `umount` entre les deux est important : on ne peut pas monter deux partages
> sur le même dossier en même temps.

#### 🪟 Windows - libérer le port 445

Windows occupe déjà le port **445** avec son propre service de partage de
fichiers. Pour héberger le conteneur SMB dessus, il faut le libérer
temporairement (**PowerShell en Administrateur**) :

```powershell
# 1. Désactiver le service SMB de Windows, puis redémarrer
Set-Service -Name LanmanServer -StartupType Disabled
Restart-Computer

# 2. Après le redémarrage : vérifier que le port 445 est libre
#    (la commande ne doit RIEN renvoyer)
Get-NetTCPConnection -LocalPort 445 -ErrorAction SilentlyContinue

# 3. Lancer le lab (Docker Desktop doit être démarré)
docker compose up -d --build
docker compose ps          # labo-smb doit être "Up"
```

Puis teste dans l'Explorateur : `\\localhost\public` (`apprenti` / `Qwertz_1234`).

**➡️ Remettre Windows comme avant, une fois le test terminé :**

```powershell
# 1. Arrêter le lab (libère le port 445)
docker compose down

# 2. Réactiver le service SMB de Windows
Set-Service -Name LanmanServer -StartupType Automatic
Start-Service -Name LanmanServer

# 3. Vérifier : Status = Running, StartType = Automatic
Get-Service LanmanServer
```

> 💡 Cette gymnastique n'est nécessaire que si tu héberges le serveur **sur
> Windows**. Le plus simple reste d'héberger sur **Linux**, où le port 445 est
> libre - les apprentis, eux, se connectent depuis Windows/Mac sans rien changer.


## 🧠 Synthèse

| Protocole | Ce que voit un attaquant sur le réseau |
|-----------|----------------------------------------|
| HTTP      | Tout, mot de passe compris (en clair)  |
| HTTPS     | Rien d'exploitable (chiffré TLS)       |
| SMB non chiffré | Le contenu des fichiers (en clair) |
| SMB3 chiffré    | Rien (« Encrypted SMB3 ») |

**Morale :** sans chiffrement, tout ce qui circule sur le réseau (mots de
passe, fichiers) est lisible par n'importe qui à l'écoute. Le chiffrement
(HTTPS, SMB3) est ce qui rend ces données illisibles.

## 🗂️ Structure du projet

```
.
├── docker-compose.yml        # orchestration des 3 services
├── web/
│   ├── app/                  # backend Flask (formulaire de login)
│   └── nginx/                # reverse proxy HTTP(80) + HTTPS(443)
├── smb/                      # serveur Samba (partages public + coffre)
├── README.md                 # cet énoncé
└── CORRIGE.md                # réponses
```

> Le corrigé complet est dans [`CORRIGE.md`](CORRIGE.md).
