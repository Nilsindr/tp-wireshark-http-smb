#!/bin/sh
set -e

SMB_USER="${SMB_USER:-apprenti}"
SMB_PASSWORD="${SMB_PASSWORD:-Qwertz_1234}"

# --- Compte Unix + compte Samba -------------------------------------------
if ! id "$SMB_USER" >/dev/null 2>&1; then
    useradd -M -s /usr/sbin/nologin "$SMB_USER"
fi
printf '%s\n%s\n' "$SMB_PASSWORD" "$SMB_PASSWORD" | smbpasswd -a -s "$SMB_USER"
smbpasswd -e "$SMB_USER" >/dev/null 2>&1 || true

# --- Contenu des partages --------------------------------------------------
mkdir -p /shares/public /shares/coffre

cat > /shares/public/message_secret.txt <<'EOF'
=========================================================
  PARTAGE NON CHIFFRE (SMB sans "smb encrypt")
=========================================================
Si tu lis ceci dans Wireshark, c'est que le contenu de ce
fichier a traverse le reseau EN CLAIR.

FLAG{smb_en_clair_c_est_dangereux}
=========================================================
EOF

cat > /shares/coffre/message_secret.txt <<'EOF'
=========================================================
  PARTAGE CHIFFRE (SMB3, smb encrypt = required)
=========================================================
Ce fichier contient aussi un secret, mais Wireshark ne
verra que "Encrypted SMB3". Impossible de le lire.

FLAG{smb3_chiffre_rien_a_voir}
=========================================================
EOF

chown -R "$SMB_USER":"$SMB_USER" /shares
chmod -R 0750 /shares

echo "[smb] Utilisateur '$SMB_USER' pret. Partages: public (clair) + coffre (chiffre)."

# Demarrage de smbd au premier plan, logs sur stdout.
exec smbd --foreground --no-process-group --debug-stdout
