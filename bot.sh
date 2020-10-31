#!/usr/bin/env bash

# =============================================================================
#
# ------------------------------------------------------------------
# bot.sh
#
# Il faut renseigner un API Token et le User Id 
# ------------------------------------------------------------------
#
# @version : 0.0.1 - 18/04/2020
# @author : Zied ZAIEM  
#
# Supported Operating Systems:
#     Debian/Ubuntu
#
# This script is linted using:
#     https://www.shellcheck.net/
#
# ------------------------------------------------------------------
# Inspiration:
#   https://github.com/fastsitephp/fastsitephp/blob/master/scripts/shell/bash/create-fast-site.sh
#   https://misc.flogisoft.com/bash/tip_colors_and_formatting
#
# =============================================================================
#
# Telegram credentials
TELEGRAM_API_TOKEN=""
# Utilisateur principal
TELEGRAM_DEFAULT_USER_CHAT_ID=""

if [ -z "$TELEGRAM_API_TOKEN" ] || [ -z "$TELEGRAM_DEFAULT_USER_CHAT_ID" ]; then
  echo "Veuillez renseigner TELEGRAM_API_TOKEN et TELEGRAM_DEFAULT_USER_CHAT_ID"
  exit 1
fi

# Variables statique globales
TELEGRAM_USER_CHAT_ID=""
JSON_RESPONSE=""

# Répertoire de données temporaires
mkdir -p "./data/"
LASTUPDATEFILE="./data/last_update_id"

# Variables du formulaire, à lire depuis $TELEGRAM_USER_CHAT_ID.conf
creationDate=$(TZ=Europe/Paris date +"%d/%m/%Y")
creationHour=$(TZ=Europe/Paris date +"%Hh%M")
lastname=""
firstname=""
birthday=""
lieunaissance=""
address=""
zipcode=""
town=""
datesortie=$(TZ=Europe/Paris date +"%d/%m/%Y")
releaseHours=$(TZ=Europe/Paris date +"%H")
releaseMinutes=$(TZ=Europe/Paris date +"%M")
reasons=""


# Binaires

# sudo apt-get install curl
CURL="curl"
# sudo apt-get install jq
JQ="jq"
# sudo apt-get install qrencode
QR="qrencode"

# sudo apt-get install build-essential gcc g++ make
# curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
# sudo apt-get install -y nodejs
NODE="nodejs"

# =============================================================================
#
# Couleurs
#
# Font Reset
F_END="\x1B[0m"
F_WHITE="\x1B[97m"
F_BLACK="\x1B[40m"
F_GRAY="\x1B[90m"
F_YELLOW="\x1B[93m"
F_BG_RED="\x1B[41m"
F_BG_BLUE="\x1B[44m"
F_BG_GREEN="\x1B[42m"
F_INFO="${F_BG_BLUE}${F_WHITE}"
F_SUCCESS="${F_BG_GREEN}${F_WHITE}"
F_WARN="${F_YELLOW}${F_BLACK}"
F_ERROR="${F_BG_RED}${F_WHITE}"
#
# =============================================================================
#
# Functions d'affichage sur écran
# Usage :  info "texte"
debug()     { echo -e "${F_GRAY}$1${F_END}"    ;}
info()      { echo -e "${F_INFO}$1${F_END}"    ;}
warn()      { echo -e "${F_WARN}$1${F_END}"    ;}
error()     { echo -e "${F_ERROR}$1${F_END}"   ;}
success()   { echo -e "${F_SUCCESS}$1${F_END}" ;}
#
# =============================================================================
#
# Fonctions Helpers d'envoi Telegram

# Envoyer un message
sendMessage() {
  text="$(echo "${@}" | sed 's:\\n:\n:g')"
  debug "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[sendMessage]\t>>\t$text"

  response=$($CURL -s \
    -X POST \
    https://api.telegram.org/bot$TELEGRAM_API_TOKEN/sendMessage \
    --data-urlencode "text=$text" \
    -d "chat_id=$TELEGRAM_USER_CHAT_ID")
    
  debug "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[sendMessage]\t<<\t$response"
  
}

# Envoyer une photo
sendPhoto() {
  caption="Attestation de déplacement dérogatoire - $firstname $lastname - $(TZ=Europe/Paris date +"%d/%m/%Y %Hh%M")"

  debug "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[sendMessage]\t>>\t$1 $caption"

  response=$($CURL -s \
    -X POST \
    https://api.telegram.org/bot$TELEGRAM_API_TOKEN/sendPhoto \
    -F chat_id="$TELEGRAM_USER_CHAT_ID" \
    -F photo="@${1}" \
    -F caption="${caption}")

  debug "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[sendMessage]\t<<\t$response"
}

sendFile() {
  debug "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[sendFile]\t>>\t$1"
  caption="Attestation de déplacement dérogatoire - $firstname $lastname - $(TZ=Europe/Paris date +"%d/%m/%Y %Hh%M")"

  response=$($CURL -s \
    -X POST \
    https://api.telegram.org/bot$TELEGRAM_API_TOKEN/sendDocument \
    -F chat_id="$TELEGRAM_USER_CHAT_ID" \
    -F document=@"$1" \
    -F caption="${caption}")

  debug "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[sendFile]\t<<\t$response"
}

# =============================================================================
#
# Gestion des messages sortants

# Envoyer Infos Système
sendInfo() {
  sendMessage $(free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }') "\n"$(df -h | awk '$NF=="/"{printf "Disk Usage: %d/%dGB (%s)\n", $3,$2,$5}') "\n"$(top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}') "\nload average:" $(uptime | awk -F'load average:' '{ print $2 }') "\nUptime: " $(uptime -p)
}

# Envoyer QR Code + Attestation
sendAttestation() {
  creationDate=$(TZ=Europe/Paris date +"%d/%m/%Y")
  creationHour=$(TZ=Europe/Paris date +"%Hh%M")
  datesortie=$(TZ=Europe/Paris date +"%d/%m/%Y")
  releaseHours=$(TZ=Europe/Paris date +"%H")
  releaseMinutes=$(TZ=Europe/Paris date +"%M")
  reasons="$1"

  genQrCode ./data/qrcode.png
  sendPhoto ./data/qrcode.png 

  genPDF ./data/attestation.pdf
  sendFile ./data/attestation.pdf 
}

# Envoyer QR Code
sendQr() {
  creationDate=$(TZ=Europe/Paris date +"%d/%m/%Y")
  creationHour=$(TZ=Europe/Paris date +"%Hh%M")
  datesortie=$(TZ=Europe/Paris date +"%d/%m/%Y")
  releaseHours=$(TZ=Europe/Paris date +"%H")
  releaseMinutes=$(TZ=Europe/Paris date +"%M")
  reasons="$1"

  genQrCode ./data/qrcode.png
  sendPhoto ./data/qrcode.png 
}

# Envoyer Attestation
sendPDF() {

  creationDate=$(TZ=Europe/Paris date +"%d/%m/%Y")
  creationHour=$(TZ=Europe/Paris date +"%Hh%M")
  datesortie=$(TZ=Europe/Paris date +"%d/%m/%Y")
  releaseHours=$(TZ=Europe/Paris date +"%H")
  releaseMinutes=$(TZ=Europe/Paris date +"%M")
  reasons="$1"

  genPDF ./data/attestation.pdf
  sendFile ./data/attestation.pdf 
}

# Générer un QR Code
genQrCode() {
  QR_STRING=$(printf "Cree le: %s a %s;\n Nom: %s;\n Prenom: %s;\n Naissance: %s a %s;\n Adresse: %s;\n Sortie: %s a %s;\n Motifs: %s" "$creationDate" "$creationHour" "$lastname" "$firstname" "$birthday" "$lieunaissance" "$address $zipcode $town" "$datesortie" "${releaseHours}h${releaseMinutes}" "$reasons")

  $QR -o "$1" -l M -m 3 -s 6 "$QR_STRING"
}

# Générer un PDF
genPDF() {

  rm -rf $1
  debug "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[genPDF]\too\t$NODE genPDF.js $1 $creationDate $creationHour $lastname $firstname $birthday $lieunaissance $address $zipcode $town $datesortie $releaseHours $releaseMinutes $reasons"

  $NODE genPDF.js "$1" "$creationDate" "$creationHour" "$lastname" "$firstname" "$birthday" "$lieunaissance" "$address" "$zipcode" "$town" "$datesortie" "$releaseHours" "$releaseMinutes" "$reasons" 

  [ -f "$1" ] && debug "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[genPDF]\tVV\t$1 créé avec succès"
}

# =============================================================================
#
# Gestion des messages entrants

# Répondre aux Sollicitations reçues
respond() {
  cmd=$1

  [ "$chatId" -lt 0 ] && cmd=${1%%@*}

  debug "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[respond]\t<<\t$cmd"

  # Commandes du Bot
  case $cmd in
    /info) sendInfo;;
    /travail) sendAttestation travail;;
    /achats) sendAttestation achats;;
    /sante) sendAttestation sante;;
    /famille) sendAttestation famille;;
    /handicap) sendAttestation handicap;;
    /sport_animaux) sendAttestation sport_animaux;;
    /convocation) sendAttestation convocation;;
    /missions) sendAttestation missions;;
    /enfants) sendAttestation enfants;;
    /help | /start) sendMessage "🤖 Motfis d'attestations disponibles:\n
    /travail - 🏢 Travail / 🏫 Formations \n
    /achats - 🛒 Achats de première nécessité \n
    /sante - 🏥 Consultations, examens et soins \n
    /famille - 👪 Motif familial impérieux \n
    /handicap - ♿ Déplacement et accompagnant \n
    /sport_animaux - 🏃 Sport & 🐕 Animaux \n
    /convocation - 🇫🇷 Service public \n
    /missions - 🔨 Missions d'intérêt général \n
    /enfants - Chercher les enfants \n
    /info - 🚸 Afficher infos service";;
    *) sendMessage "Commande '$cmd' inconnue"
  esac

}

# Récupérer le dernier message depuis la dernier marqué dans $LASTUPDATEFILE
readNext() {
  lastUpdateId=$(cat $LASTUPDATEFILE || echo "0")
  JSON_RESPONSE=$($CURL -s -X GET "https://api.telegram.org/bot$TELEGRAM_API_TOKEN/getUpdates?offset=$lastUpdateId&limit=1&allowed_updates=message")
}

# Marquer le message comme lu localement
markAsRead() {
  nextId=$(($1 + 1))
  echo "$nextId" > $LASTUPDATEFILE
  debug "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[markAsRead]\t✓✓\t$nextId marqué comme lu."
  debug "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[markAsRead]\t--\t------------------------------------------"
}

# =============================================================================
#
# Main

main() {
  # Lire le prochain message
  readNext

  # Retour si la réponse est vide
  [ -z "$JSON_RESPONSE" ] && return 0

  # Sortie si Erreur de Bot
  if [ "$(echo "$JSON_RESPONSE" | $JQ -r '.ok')" != "true" ]; then
    error "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[markAsRead]\t\tBot error: $JSON_RESPONSE"
    [ "$(echo "$JSON_RESPONSE" | $JQ -r '.error_code')" == "401" ] && return 1
    return 0
  fi;

  # Essayer de récupérer le message
  messageAttr="message"

  # Si le message a été modifié, les attributs changent
  messageVal=$(echo "$JSON_RESPONSE" | $JQ -r '.result[0].message // ""')
  [ -z "$messageVal" ] && messageAttr="edited_message"

  # Destinataire
  chatId=$(echo "$JSON_RESPONSE" | $JQ -r ".result[0].$messageAttr.chat.id // \"\"")

  # Id du message
  updateId=$(echo "$JSON_RESPONSE" | $JQ -r '.result[0].update_id // ""')

  # Si pas destinataire, marqué comme lu et sortir
  if [ "$updateId" != "" ] && [ -z "$chatId" ]; then                                                                           
    markAsRead "$updateId"                                                                              
    return 0                                                                                             
  fi;
  
  [ -z "$chatId" ] && return 0 # no new messages

  # Récupérer le texte
  cmd=$(echo "$JSON_RESPONSE" | $JQ -r ".result[0].$messageAttr.text // \"\"")

  debug "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[main]\t--\t------------------------------------------"

  # Si on trouve le formulaire de cet user (${chatId}.conf), on charge les données
  if [ -f "./${chatId}.conf" ]; then 
    TELEGRAM_USER_CHAT_ID="$chatId"
    debug "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[main]\too\tChargement de ${chatId}.conf"
    . "./${chatId}.conf"
  else
    TELEGRAM_USER_CHAT_ID=""
  fi

  # Si pas conf, on envoi un message TELEGRAM_DEFAULT_USER_CHAT_ID pour l'informer
  if [ "$TELEGRAM_USER_CHAT_ID" = "" ]; then
    TELEGRAM_USER_CHAT_ID=$TELEGRAM_DEFAULT_USER_CHAT_ID

    username=$(echo "$JSON_RESPONSE" | $JQ -r ".result[0].$messageAttr.from.username // \"\"")
    firstName=$(echo "$JSON_RESPONSE" | $JQ -r ".result[0].$messageAttr.from.first_name // \"\"")

    sendMessage "Message reçu d'un user non autorisé: \nId :$chatId\nUtilisateur: $username ($firstName)\nMessage: $cmd"
    warn "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[main]\t\tReceived message from unauthorized chat id: $chatId, User: $username($firstName), Message: $cmd"
  else
    # Répondre au message
    respond "$cmd"
  fi;

  # Le marquer comme lu
  markAsRead "$updateId"

  # Nettoyer la variable globale
  TELEGRAM_USER_CHAT_ID=""
}

# =============================================================================
# 
# Boucle Principale
info "$(TZ=Europe/Paris date +"%d/%m/%Y %H:%M:%S")\t[bot.sh]\t\tBot démarré"

while true; do
  main
  [ $? -gt 0 ] && exit 1
  # Vérifier toutes les 2 secondes
  sleep 2
done;