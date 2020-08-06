#!/bin/bash

#####################
#                   #
#   CONFIGURATION   #  
#                   #
#####################



##############
#            #
#   DISQUE   #
#            #
##############

# Nom du disque monté ou la backup local s'enregistrera
disk='disque1'


##############
#            #
#  DOSSIERS  #
#            #
##############

# Sauvegarder WWW ?
www='false'

# Sauvegarder MARIADB ?
mariadb='true'

# Sauvegarder le dossier /SRV ?
srv='true'


##############
#            #
#   UPLOAD   #
#            #
##############

# Uploader la sauvegarde en offsite Google Cloud ?
offsite='true'

# Nom du bucket sur lequel upload
bucket='gs://testbucket/folder'

##############
#            #
#    RGPD    #
#            #
##############

# Définir une politque de suppression des données ?
policy='true'

# Combien de jours souhaitez vous conserver les sauvegardes ?
conservation='31'


#####################
#                   #
#       CODE        #
#                   #
#####################

# Déclaration de la date et l'heure de la sauvegarde
date=$(date +%d-%m-%Y-%H-%M)

# Créations des dossiers dans le disque
mkdir /mnt/$disk/backup
mkdir /mnt/$disk/backup/www
mkdir /mnt/$disk/backup/mysql
mkdir /mnt/$disk/backup/srv

if [ $www = "true" ]
    then
        echo "Sauvegarde du dossier WWW..."
        tar -czf /mnt/$disk/backup/www/sites_$date.tgz -C /var/www .
    else
        echo "Sauvegarde du dossier WWW désactivé"
fi

if [ $mariadb = "true" ]
    then
        echo "Sauvegarde de MariaDB..."
        tar -czf /mnt/$disk/backup/mysql/mysql_$date.tgz -C /var/lib/mysql .
    else
        echo "Sauvegarde de MariaDB désactivé"
fi

if [ $srv = "true" ]
    then
        echo "Sauvegarde du dossier SRV..."
        tar --exclude='*.gma' --exclude='*.vpk' --exclude="*.bin" -czf /mnt/$disk/backup/srv/srv_$date.tgz -C /srv .
    else
        echo "Sauvegarde du dossier SRV désactivé"
fi

if [ $offsite = "true" ]
    then
        echo "Upload de la sauvegarde sur Google Cloud"
        gsutil cp /mnt/$disk/backup/mysql/mysql_$date.tgz $bucket
        gsutil cp /mnt/$disk/backup/www/sites_$date.tgz $bucket
        gsutil cp /mnt/$disk/backup/srv/srv_$date.tgz $bucket
    else
        echo "Pas de sauvegarde sur Google Cloud"
fi

if [ $policy = "true" ]
    then
        echo "Suppression des fichiers datant de plus de" $conservation "jours"
        find /mnt/$disk/backup/mysql -name "*.tgz" -type f -mtime +$conservation -exec rm -f {} \;
        find /mnt/$disk/backup/www -name "*.tgz" -type f -mtime +$conservation -exec rm -f {} \;
        find /mnt/$disk/backup/srv -name "*.tgz" -type f -mtime +$conservation -exec rm -f {} \;
    else
        echo "Pas de suppression automatique des fichiers"
fi