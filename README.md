# Covid-19-Telegram-Bot

Un bot [Telegram](https://telegram.org/) pour générer rapidement l'attestation de déplacement dérogatoire.

[![Known Vulnerabilities](https://snyk.io/test/github/ziedzaiem/Covid-19-Telegram-Bot/badge.svg?targetFile=package.json)](https://snyk.io/test/github/ziedzaiem/Covid-19-Telegram-Bot?targetFile=package.json)

![Icône](icon.png)

Ce bot est basé sur le [code source]((https://github.com/LAB-MI/deplacement-covid-19) ) du [générateur officiel de l'attestation de déplacement dérogatoire](https://media.interieur.gouv.fr/deplacement-covid-19/) 

## Comment ça marche ?

L'idée est de demander au bot de générer automatiquement le QR Code et PDF obtenus d'habitude par le formulaire numérique. Il suffit d'envoyer au bot l'unde des commandes suivantes pour générer une attestation avec le motif voulu :

- /travail - Attestation pour motif : Travail 🏢
- /courses - Attestation pour motif : Courses 🛒
- /sante - Attestation pour motif : Santé 🏥
- /sport - Attestation pour motif : Sport 🏃\n
- /info - Afficher infos techniques du service

![Screenshot](screenshot.png)

## Configuration

Il y a deux paramètres à renseigner dans le **bot.sh**:

- **TELEGRAM_API_TOKEN** : Le API Token utilisé par le bot. A récupérer lors de la création du bot, en utilisant le bot @BotFather par exemple.
- **TELEGRAM_DEFAULT_USER_CHAT_ID** : L'id de l'utilisateur Télégram. Le but est de protéger le bot pour n'envoyer des messages qu'aux personnes autorisées. L'id est récupérable en contactant le bot @userinfobot .

Pour autoriser un utilisateur, il faut créer un fichier de conf se nommant *id*.conf avec *id* l'id utilisateur récupéré précédemment. Ce fichier contient les données du formulaires d'attestation. Le fichier [exemple.conf](exemple.conf) contient des données d'exemple.

## Développement

Vous aurez besoin d'un Ubuntu avec curl, qrencode, jq et NodeJS installés pour travailler en local.

Commencer par installer les dépendances JavaScript :

```shell
npm install
```

Renseigner TELEGRAM_API_TOKEN et TELEGRAM_DEFAULT_USER_CHAT_ID dans bot.sh, créer un fichier de configuration avec l'id utilisateur. Ensuite lancer le bot:

```bash
./bot.sh
```

Il suffit d'envoyer des commandes au bot pour recevoir l'attestation.

## Déploiement

Si vous avez Docker et docker-compose installés, il suffit de lancer le script [deploy.sh](deploy.sh) qui va construire l'image Docker et la lancer.

```shell
docker-compose down && docker-compose build && docker-compose up -d
```

## Crédits

Ce projet a été réalisé à partir d'un fork des dépôts [deplacement-covid-19]((https://github.com/LAB-MI/deplacement-covid-19) de l'Incubateur du ministère de l'intérieur et [covid-19-certificate](https://github.com/nesk/covid-19-certificate) de [Johann Pardanaud](https://github.com/nesk).

## Licence

MIT.
